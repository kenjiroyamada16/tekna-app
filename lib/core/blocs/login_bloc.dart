import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../di/injector.dart';

// Events
abstract class LoginEvent {}

class LoginWithEmailPassword extends LoginEvent {
  final String email;
  final String password;

  LoginWithEmailPassword({required this.email, required this.password});
}

class EmailChanged extends LoginEvent {
  final String email;

  EmailChanged({required this.email});
}

class PasswordChanged extends LoginEvent {
  final String password;
  PasswordChanged({required this.password});
}

class LoginInit extends LoginEvent {}

// States
class LoginState {
  final String? emailErrorMessage;
  final String? passwordErrorMessage;

  LoginState({this.emailErrorMessage, this.passwordErrorMessage});

  LoginState copyWith({String? emailErrorMessage, String? passwordErrorMessage}) {
    return LoginState(
      emailErrorMessage: emailErrorMessage ?? this.emailErrorMessage,
      passwordErrorMessage: passwordErrorMessage ?? this.passwordErrorMessage,
    );
  }
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginFailure extends LoginState {
  final String? errorMessage;

  LoginFailure({this.errorMessage});
}

class LoginSuccess extends LoginState {}

// Bloc
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginInit>((_, emit) => emit(LoginInitial()));
    on<LoginWithEmailPassword>(_loginWithEmailPassword);
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
  }

  Future<void> _loginWithEmailPassword(LoginWithEmailPassword event, Emitter<LoginState> emit) async {
    if (state is LoginLoading) return;

    final emailError = _validateEmail(event.email);
    final passwordError = _validatePassword(event.password);

    if (emailError.isNotEmpty || passwordError.isNotEmpty) {
      return emit(state.copyWith(emailErrorMessage: emailError, passwordErrorMessage: passwordError));
    }

    emit(LoginLoading());

    try {
      final supabaseService = ServiceLocator.get<SupabaseServiceProtocol>();
      await supabaseService.loginWithEmailAndPassword(email: event.email, password: event.password);

      if (await supabaseService.currentSession != null) {
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(errorMessage: 'Não foi possível realizar o login. Por favor, tente novamente.'));
      }
    } on Exception catch (exception) {
      if (exception is AuthApiException && exception.statusCode == '400') {
        return emit(LoginFailure(errorMessage: 'Credenciais inválidas'));
      }

      emit(LoginFailure(errorMessage: 'Ocorreu um erro na requisição. Por favor, tente novamente'));
    }
  }

  Future<void> _onEmailChanged(EmailChanged event, Emitter<LoginState> emit) async {
    final emailError = _validateEmail(event.email);

    emit(state.copyWith(emailErrorMessage: emailError));
  }

  Future<void> _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) async {
    final passwordError = _validatePassword(event.password);

    emit(state.copyWith(passwordErrorMessage: passwordError));
  }

  String _validateEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (email.isEmpty) return 'Informe o e-mail';

    if (!emailRegex.hasMatch(email)) return 'E-mail inválido';

    return '';
  }

  String _validatePassword(String password) {
    if (password.isEmpty) return 'Informe a senha';

    return '';
  }
}
