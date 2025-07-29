import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/supabase_service.dart';
import '../di/injector.dart';

// Events
abstract class RegisterAccountEvent {}

class RegisterAccountWithEmailPassword extends RegisterAccountEvent {
  final String email;
  final String password;

  RegisterAccountWithEmailPassword({required this.email, required this.password});
}

class RegisterEmailChanged extends RegisterAccountEvent {
  final String email;

  RegisterEmailChanged({required this.email});
}

class RegisterPasswordChanged extends RegisterAccountEvent {
  final String password;
  RegisterPasswordChanged({required this.password});
}

class RegisterAccountInit extends RegisterAccountEvent {}

// States
class RegisterAccountState {
  final String? emailErrorMessage;
  final String? passwordErrorMessage;

  RegisterAccountState({this.emailErrorMessage, this.passwordErrorMessage});

  RegisterAccountState copyWith({String? emailErrorMessage, String? passwordErrorMessage}) {
    return RegisterAccountState(
      emailErrorMessage: emailErrorMessage ?? this.emailErrorMessage,
      passwordErrorMessage: passwordErrorMessage ?? this.passwordErrorMessage,
    );
  }
}

class RegisterAccountInitial extends RegisterAccountState {}

class RegisterAccountLoading extends RegisterAccountState {}

class RegisterAccountFailure extends RegisterAccountState {
  final String? errorMessage;

  RegisterAccountFailure({this.errorMessage});
}

class RegisterAccountSuccess extends RegisterAccountState {
  final bool hasSession;

  RegisterAccountSuccess({this.hasSession = false});
}

// Bloc
class RegisterAccountBloc extends Bloc<RegisterAccountEvent, RegisterAccountState> {
  RegisterAccountBloc() : super(RegisterAccountInitial()) {
    on<RegisterAccountInit>((_, emit) => emit(RegisterAccountInitial()));
    on<RegisterAccountWithEmailPassword>(_registerAccountWithEmailPassword);
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
  }

  Future<void> _registerAccountWithEmailPassword(
    RegisterAccountWithEmailPassword event,
    Emitter<RegisterAccountState> emit,
  ) async {
    if (state is RegisterAccountLoading) return;

    final emailError = _validateEmail(event.email);
    final passwordError = _validatePassword(event.password);

    if (emailError.isNotEmpty || passwordError.isNotEmpty) {
      return emit(
        state.copyWith(emailErrorMessage: emailError, passwordErrorMessage: passwordError),
      );
    }

    emit(RegisterAccountLoading());

    try {
      final supabaseService = ServiceLocator.get<SupabaseServiceProtocol>();
      await supabaseService.registerAccountEmailPassword(
        email: event.email,
        password: event.password,
      );

      emit(RegisterAccountSuccess(hasSession: await supabaseService.currentSession != null));
    } on Exception catch (_) {
      emit(
        RegisterAccountFailure(
          errorMessage: 'Ocorreu um erro na requisição. Por favor, tente novamente',
        ),
      );
    }
  }

  Future<void> _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterAccountState> emit,
  ) async {
    final emailError = _validateEmail(event.email);

    emit(state.copyWith(emailErrorMessage: emailError));
  }

  Future<void> _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterAccountState> emit,
  ) async {
    final passwordError = _validatePassword(event.password);

    emit(state.copyWith(passwordErrorMessage: passwordError));
  }

  String _validateEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (email.isEmpty) return 'Informe o e-mail';

    if (!emailRegex.hasMatch(email)) return 'E-mail inválido';

    return '';
  }

  String _validatePassword(String password) {
    if (password.isEmpty) return 'Informe a senha';

    return '';
  }
}
