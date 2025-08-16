import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatbytes/auth/presentation/bloc/auth_bloc.dart';
import 'package:whatbytes/auth/presentation/bloc/auth_event.dart';
import 'package:whatbytes/auth/presentation/bloc/auth_state.dart';
import 'package:whatbytes/core/theme/app_color.dart';

class AccountDrawer extends StatelessWidget {
  const AccountDrawer();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final email =
        (state is Authenticated) ? (state.user.email ?? 'No email') : 'Guest';

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pretty header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColor.primary),
            accountName: null,
            accountEmail: Text(
              email,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, color: AppColor.primary),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign out'),
            onTap: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
    );
  }
}
