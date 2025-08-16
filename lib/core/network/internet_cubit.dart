import 'dart:async';
import 'dart:io' show HttpClient, HttpClientResponse;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

enum NetHealth { online, unstable, offline }

class InternetState {
  final NetHealth status;
  final Duration? avgRtt; // average latency over window
  final double lossRate; // 0..1 in window
  final String? reason; // optional extra info
  const InternetState({
    required this.status,
    this.avgRtt,
    this.lossRate = 0,
    this.reason,
  });

  InternetState copyWith({
    NetHealth? status,
    Duration? avgRtt,
    double? lossRate,
    String? reason,
  }) => InternetState(
    status: status ?? this.status,
    avgRtt: avgRtt ?? this.avgRtt,
    lossRate: lossRate ?? this.lossRate,
    reason: reason ?? this.reason,
  );

  @override
  String toString() =>
      'InternetState($status, rtt=${avgRtt?.inMilliseconds}ms, loss=${(lossRate * 100).toStringAsFixed(0)}%)';
}

class InternetCubit extends Cubit<InternetState> {
  InternetCubit({
    this.windowSize = 6,
    this.pingInterval = const Duration(seconds: 3),
    this.timeoutPerProbe = const Duration(seconds: 2),
    List<Uri>? endpoints,
    this.unstableRtt = const Duration(milliseconds: 800),
    this.unstableLoss = 0.4,
  }) : super(const InternetState(status: NetHealth.online)) {
    _endpoints =
        endpoints ??
        const [
          // lightweight 204 endpoints
          'https://www.gstatic.com/generate_204',
          'https://clients3.google.com/generate_204',
          'https://www.google.com/generate_204',
          // neutral CDN fallback
          'https://cloudflare-dns.com/dns-query', // will 405 on HEAD, we only need reachability
        ].map(Uri.parse).toList();

    _start();
  }

  final int windowSize;
  final Duration pingInterval;
  final Duration timeoutPerProbe;
  final Duration unstableRtt;
  final double unstableLoss;

  late final List<Uri> _endpoints;
  int _endpointIndex = 0;

  final _samples = <_ProbeSample>[];
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  Timer? _timer;
  bool _hadAnySuccess = true; // avoid false "offline" at launch

  // public: force a probe now (e.g., from a Retry button)
  Future<void> pingNow() async => _probeAndEvaluate();

  void _start() {
    // Listen to link changes
    _connSub = Connectivity().onConnectivityChanged.listen(
      (_) => _probeAndEvaluate(),
    );
    // Kickoff periodic probing
    _timer = Timer.periodic(pingInterval, (_) => _probeAndEvaluate());
    // Initial immediate probe
    _probeAndEvaluate();
  }

  Future<void> _probeAndEvaluate() async {
    final sample = await _probeOnce();
    _samples.add(sample);
    if (_samples.length > windowSize) _samples.removeAt(0);

    // compute metrics
    final successes = _samples.where((s) => s.ok).toList();
    final loss =
        _samples.isEmpty ? 0.0 : 1 - (successes.length / _samples.length);
    final avg =
        successes.isEmpty
            ? null
            : Duration(
              milliseconds:
                  successes
                      .map((s) => s.rtt.inMilliseconds)
                      .reduce((a, b) => a + b) ~/
                  successes.length,
            );

    // Decide status
    NetHealth next;
    String? reason;

    // If link says "none" OR last N failed, call offline
    final conn = await Connectivity().checkConnectivity();
    final linkDown = conn.every((r) => r == ConnectivityResult.none);
    final lastAllFailed =
        _samples.length >= 3 &&
        _samples.sublist(_samples.length - 3).every((s) => !s.ok);

    if (linkDown ||
        (!_hadAnySuccess && lastAllFailed) ||
        (successes.isEmpty && _samples.length >= 2)) {
      next = NetHealth.offline;
      reason = linkDown ? 'No network' : 'No internet';
    } else if ((avg != null && avg > unstableRtt) || (loss > unstableLoss)) {
      next = NetHealth.unstable;
      reason = 'High latency or packet loss';
    } else {
      next = NetHealth.online;
    }

    if (successes.isNotEmpty) _hadAnySuccess = true;

    // Avoid chatty toggling: only emit if status or key metrics change meaningfully
    final prev = state;
    final changedStatus = prev.status != next;
    final changedQuality =
        (prev.avgRtt?.inMilliseconds ?? -1) != (avg?.inMilliseconds ?? -1) ||
        (prev.lossRate - loss).abs() > 0.15;

    if (changedStatus || changedQuality) {
      emit(
        InternetState(
          status: next,
          avgRtt: avg,
          lossRate: loss,
          reason: reason,
        ),
      );
    }
  }

  Future<_ProbeSample> _probeOnce() async {
    final url = _endpoints[_endpointIndex];
    _endpointIndex = (_endpointIndex + 1) % _endpoints.length;

    final sw = Stopwatch()..start();
    try {
      if (kIsWeb) {
        // web: use package:http (works in browser)
        final resp = await http.head(url).timeout(timeoutPerProbe);
        sw.stop();
        return _ProbeSample(
          ok: resp.statusCode < 400,
          rtt: Duration(milliseconds: sw.elapsedMilliseconds),
        );
      } else {
        // mobile/desktop: dart:io HttpClient for lower overhead
        final client = HttpClient()..connectionTimeout = timeoutPerProbe;
        client.userAgent = 'whatbytes-probe';
        final req = await client.headUrl(url).timeout(timeoutPerProbe);
        final resp = await req.close().timeout(timeoutPerProbe);
        // drain (not strictly needed, but tidy)
        await resp.drain<List<int>>();
        client.close(force: true);
        sw.stop();
        final ok = (resp as HttpClientResponse).statusCode < 400;
        return _ProbeSample(ok: ok, rtt: sw.elapsed);
      }
    } catch (_) {
      sw.stop();
      return _ProbeSample(ok: false, rtt: sw.elapsed);
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _connSub?.cancel();
    return super.close();
  }
}

class _ProbeSample {
  final bool ok;
  final Duration rtt;
  _ProbeSample({required this.ok, required this.rtt});
}
