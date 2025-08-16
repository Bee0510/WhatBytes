import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:whatbytes/auth/presentation/bloc/auth_event.dart';
import 'package:whatbytes/auth/presentation/bloc/auth_state.dart';
import 'package:whatbytes/core/theme/app_color.dart';
import 'package:whatbytes/core/utils/toast.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../../../core/utils/validators.dart';
import '../widgets/auth_shared.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            final errorMessage = state.message;
            if (errorMessage.contains('invalid-email')) {
              ToastUtils.showCustomToast(
                'The email address is not valid. Please check and try again.',
              );
            } else if (errorMessage.contains('invalid-credential')) {
              ToastUtils.showCustomToast(
                'No user found with this email. Please register first.',
              );
            } else if (errorMessage.contains('wrong-password')) {
              ToastUtils.showCustomToast(
                'Incorrect password. Please try again.',
              );
            } else {
              ToastUtils.showCustomToast('Login failed: $errorMessage');
            }
          }
          if (state is Authenticated) {
            ToastUtils.showCustomToast('Welcome back, ${state.user.email}!');
            context.go('/');
          }
        },
        builder: (context, state) {
          print('LoginPage state: $state');
          final loading = state is AuthLoading;
          return AuthShell(
            title: 'Welcome back!',
            subtitle: 'Log in to continue planning your tasks',
            primaryButtonText: 'Log in',
            loading: loading,
            onPrimaryPressed: () {
              if (_formKey.currentState!.validate()) {
                context.read<AuthBloc>().add(
                  SignInRequested(_email.text.trim(), _password.text.trim()),
                );
              }
            },
            helperText: 'or log in with',
            footerText: "Don’t have an account?",
            footerActionText: "Get started!",
            onFooterTap: () => context.push('/register'),
            formChildren: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthField(
                      controller: _email,
                      label: 'EMAIL ADDRESS',
                      validator:
                          (v) => Validators.requiredField(v, label: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    AuthField(
                      controller: _password,
                      label: 'Password',
                      obscure: true,
                      isLogin: true,
                      onForgotPassword: () async {
                        final email = _email.text.trim();
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter your email first'),
                            ),
                          );
                          return;
                        }
                        try {
                          // If you’re using FirebaseAuth:
                          // await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Password reset email sent to $email',
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not send reset email: $e'),
                            ),
                          );
                        }
                      },
                      validator:
                          (v) => Validators.requiredField(v, label: 'Password'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
