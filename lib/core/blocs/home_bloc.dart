import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/domain/app_exception.dart';
import '../../data/entities/task.dart';
import '../di/injector.dart';
import '../services/supabase_service.dart';

// Events
abstract class HomeEvent {}

class HomeLoadTasks extends HomeEvent {}

class HomeRefreshTasks extends HomeEvent {}

// States
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<Task> tasks;

  HomeSuccess(this.tasks);
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}

// Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  late final SupabaseServiceProtocol _supabaseService;

  HomeBloc() : super(HomeInitial()) {
    _supabaseService = ServiceLocator.get<SupabaseServiceProtocol>();

    on<HomeLoadTasks>(_onLoadTasks);
  }

  Future<void> _onLoadTasks(HomeLoadTasks event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    try {
      final tasks = await _supabaseService.getUserTasks();

      emit(HomeSuccess(tasks));
    } on Exception catch (e) {
      if (e is AppException) emit(HomeError(e.userFriendlyMessage));
    }
  }
}
