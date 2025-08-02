import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/domain/app_exception.dart';
import '../../data/entities/task.dart';
import '../di/injector.dart';
import '../services/supabase_service.dart';

// Events
abstract class HomeEvent {}

class HomeLoadTasks extends HomeEvent {}

class HomeRefreshTasks extends HomeEvent {}

class HomeCreateTask extends HomeEvent {
  final Task newTask;

  HomeCreateTask({required this.newTask});
}

class HomeShowCreateTaskDialog extends HomeEvent {}

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

class HomeCreateTaskDialog extends HomeState {
  final List<String> categories;

  HomeCreateTaskDialog(this.categories);
}

// Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final _categoriesList = List<String>.empty(growable: true);

  late final SupabaseServiceProtocol _supabaseService;

  HomeBloc() : super(HomeInitial()) {
    _supabaseService = ServiceLocator.get<SupabaseServiceProtocol>();

    on<HomeLoadTasks>(_onLoadTasks);
    on<HomeCreateTask>(_onCreateTask);
    on<HomeShowCreateTaskDialog>(_showCreateTaskDialog);
  }

  Future<void> _onLoadTasks(
    HomeLoadTasks event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      final tasks = await _supabaseService.getUserTasks();
      final categories = await _supabaseService.getUserCategories();

      _categoriesList.addAll(categories);

      emit(HomeSuccess(tasks));
    } on Exception catch (e) {
      if (e is AppException) emit(HomeError(e.userFriendlyMessage));
    }
  }

  Future<void> _onCreateTask(
    HomeCreateTask event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _supabaseService.createTask(event.newTask);

      final tasks = await _supabaseService.getUserTasks();

      emit(HomeSuccess(tasks));
    } on Exception catch (e) {
      if (e is AppException) {
        emit(HomeError(e.userFriendlyMessage));
      } else {
        emit(HomeError('Error creating task'));
      }
    }
  }

  Future<void> _showCreateTaskDialog(
    HomeShowCreateTaskDialog event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeCreateTaskDialog(_categoriesList));
  }
}
