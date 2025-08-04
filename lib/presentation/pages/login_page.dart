import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/login_bloc.dart';
import '../../core/router/app_router.dart';
import '../../shared/components/app_text_field.dart';
import '../../style/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginBloc _bloc;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _bloc = context.read<LoginBloc>();
    _bloc.add(LoginInit());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocConsumer<LoginBloc, LoginState>(
              listener: (_, state) {
                if (state is LoginSuccess) _navigateHome();

                if (state is LoginFailure && state.errorMessage != null) {
                  _showMessage(state.errorMessage ?? '');
                }
              },
              builder: (_, state) {
                final hasFormError =
                    (state.emailErrorMessage?.isNotEmpty ?? false) ||
                    (state.passwordErrorMessage?.isNotEmpty ?? false);

                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Enter your email and password to proceed!'),
                      SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        errorMessage: state.emailErrorMessage?.isEmpty ?? true
                            ? null
                            : state.emailErrorMessage,
                        onChanged: (value) =>
                            _bloc.add(LoginEmailChanged(email: value)),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        keyboardType: TextInputType.text,
                        isObscure: true,
                        errorMessage:
                            state.passwordErrorMessage?.isEmpty ?? true
                            ? null
                            : state.passwordErrorMessage,
                        onChanged: (value) =>
                            _bloc.add(LoginPasswordChanged(password: value)),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRouter.registerAccountroute,
                          ),
                          child: Text(
                            "Don't have an account yet? Create one now.",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: hasFormError ? null : _onLoginPressed,
                          child: state is LoginLoading
                              ? SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    color: AppColors.backgroundColor,
                                  ),
                                )
                              : const Text('Sign in'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    _bloc.add(LoginWithEmailPassword(email: email, password: password));
  }

  void _navigateHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMessage('Authenticated successfully');
      Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
    });
  }

  void _showMessage(String message, [Color? color]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final snackbar = SnackBar(
        backgroundColor: color ?? AppColors.primaryColor,
        content: Text(message),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }
}
