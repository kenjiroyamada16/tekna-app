import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/supabase_service.dart';
import '../di/injector.dart';

// Events
abstract class SplashEvent {}

class SplashStarted extends SplashEvent {}

// States
abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashSuccess extends SplashState {
  final bool hasSession;

  SplashSuccess({this.hasSession = false});
}

// Bloc
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onStarted);
  }

  Future<void> _onStarted(SplashStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());

    await Future.delayed(const Duration(seconds: 3));

    final supabaseService = ServiceLocator.get<SupabaseServiceProtocol>();
    await supabaseService.initialize();
    final currentSession = await supabaseService.currentSession;

    emit(SplashSuccess(hasSession: currentSession != null));
  }
}
