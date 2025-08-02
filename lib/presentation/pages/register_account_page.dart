import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/register_account_bloc.dart';
import '../../core/router/app_router.dart';
import '../../shared/components/app_text_field.dart';
import '../../style/app_colors.dart';

class RegisterAccountPage extends StatefulWidget {
  const RegisterAccountPage({super.key});

  @override
  State<RegisterAccountPage> createState() => _RegisterAccountPageState();
}

class _RegisterAccountPageState extends State<RegisterAccountPage> {
  late final RegisterAccountBloc _bloc;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _bloc = context.read<RegisterAccountBloc>();
    _bloc.add(RegisterAccountInit());
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
            child: BlocConsumer<RegisterAccountBloc, RegisterAccountState>(
              listener: (_, state) {
                if (state is RegisterAccountSuccess) {
                  _handleAccountRegistration(state.hasSession);
                }

                if (state is RegisterAccountFailure &&
                    state.errorMessage != null) {
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
                        'Register account',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Enter your email and password to register an account!'),
                      SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        label: 'E-mail',
                        keyboardType: TextInputType.emailAddress,
                        errorMessage: state.emailErrorMessage?.isEmpty ?? true
                            ? null
                            : state.emailErrorMessage,
                        onChanged: (value) {
                          _bloc.add(RegisterEmailChanged(email: value));
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Senha',
                        keyboardType: TextInputType.text,
                        isObscure: true,
                        errorMessage:
                            state.passwordErrorMessage?.isEmpty ?? true
                            ? null
                            : state.passwordErrorMessage,
                        onChanged: (value) {
                          _bloc.add(RegisterPasswordChanged(password: value));
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRouter.loginRoute,
                          ),
                          child: Text(
                            'Already have an account? Sign in now!',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: hasFormError ? null : _onTapCreateAccount,
                          child: state is RegisterAccountLoading
                              ? SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    color: AppColors.backgroundColor,
                                  ),
                                )
                              : const Text('Register account'),
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

  void _onTapCreateAccount() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    _bloc.add(
      RegisterAccountWithEmailPassword(email: email, password: password),
    );
  }

  void _handleAccountRegistration(bool hasSession) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasSession) {
        _showMessage('Registered and authenticated successfully');
        Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
      } else {
        _showMessage('Account created successfully');
        Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
      }
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
