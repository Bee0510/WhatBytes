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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      resizeToAvoidBottomInset: false,
      body: BlocListener<AuthBloc, AuthState>(
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
            } else if (errorMessage.contains('email-already-in-use')) {
              ToastUtils.showCustomToast(
                'Incorrect password. Please try again.',
              );
            } else if (errorMessage.contains('weak-password')) {
              ToastUtils.showCustomToast(
                'The password provided is too weak or short.',
              );
            }
          }
          if (state is Authenticated) {
            context.go('/');
          }
        },
        child: Builder(
          builder: (context) {
            final loading = context.watch<AuthBloc>().state is AuthLoading;
            return AuthShell(
              title: "Let's get started!",
              subtitle: 'Create an account to plan and track your tasks',
              primaryButtonText: 'Sign up',
              loading: loading,
              onPrimaryPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<AuthBloc>().add(
                    SignUpRequested(_email.text.trim(), _password.text.trim()),
                  );
                }
              },
              helperText: 'or sign up with',
              footerText: "Already have an account?",
              footerActionText: "Log in",
              onFooterTap: () => context.go('/login'),
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
                        label: 'PASSWORD',
                        obscure: true,
                        canToggleObscure: true,
                        validator:
                            (v) =>
                                Validators.requiredField(v, label: 'Password'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
