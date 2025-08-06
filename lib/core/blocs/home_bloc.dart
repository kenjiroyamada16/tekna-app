import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/domain/app_exception.dart';
import '../../data/entities/task.dart';
import '../../data/entities/task_category.dart';
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

class HomeEditTask extends HomeEvent {
  final Task task;

  HomeEditTask(this.task);
}

class HomeShowEditTaskDialog extends HomeEvent {
  final Task task;

  HomeShowEditTaskDialog(this.task);
}

class HomeShowCreateTaskDialog extends HomeEvent {}

class HomeShowDeleteTaskBottomSheet extends HomeEvent {
  final int taskId;

  HomeShowDeleteTaskBottomSheet(this.taskId);
}

class HomeConfirmDeleteTask extends HomeEvent {
  final int taskId;

  HomeConfirmDeleteTask(this.taskId);
}

class HomeUpdateCategories extends HomeEvent {
  final List<TaskCategory> updatedCategories;

  HomeUpdateCategories(this.updatedCategories);
}

class HomeLogout extends HomeEvent {}

class HomeSearchTask extends HomeEvent {
  final String? query;

  HomeSearchTask(this.query);
}

// States
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<Task> tasks;
  final String? message;

  HomeSuccess({required this.tasks, this.message});
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}

class HomeCreateTaskDialog extends HomeState {
  final List<TaskCategory> categories;

  HomeCreateTaskDialog(this.categories);
}

class HomeEditTaskDialog extends HomeState {
  final Task task;
  final List<TaskCategory> categories;

  HomeEditTaskDialog(this.task, this.categories);
}

class HomeDeleteTaskBottomSheet extends HomeState {
  final int taskId;

  HomeDeleteTaskBottomSheet(this.taskId);
}

class HomeGoBackToLogin extends HomeState {}

class HomeFilteredTasks extends HomeState {
  final List<Task> filteredTasks;

  HomeFilteredTasks(this.filteredTasks);
}

// Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final _tasksList = List<Task>.empty(growable: true);
  final _categoriesList = List<TaskCategory>.empty(growable: true);

  late final SupabaseServiceProtocol _supabaseService;

  HomeBloc() : super(HomeInitial()) {
    _supabaseService = ServiceLocator.get<SupabaseServiceProtocol>();

    on<HomeLoadTasks>(_onLoadTasks);
    on<HomeCreateTask>(_onCreateTask);
    on<HomeShowCreateTaskDialog>(_showCreateTaskDialog);
    on<HomeShowDeleteTaskBottomSheet>(_showDeleteTaskBottomSheet);
    on<HomeConfirmDeleteTask>(_onConfirmDeleteTask);
    on<HomeShowEditTaskDialog>(_showEditTaskDialog);
    on<HomeEditTask>(_onEditTask);
    on<HomeUpdateCategories>(_onUpdateCategories);
    on<HomeLogout>(_onLogoutUser);
    on<HomeSearchTask>(_onSearchTasks);
  }

  Future<void> _onLoadTasks(
    HomeLoadTasks event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      final tasks = await _supabaseService.getUserTasks();
      final categories = await _supabaseService.getUserCategories();

      _tasksList.clear();
      _tasksList.addAll(tasks);
      _categoriesList.clear();
      _categoriesList.addAll(categories);

      emit(HomeSuccess(tasks: _tasksList));
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

      _tasksList.clear();
      _tasksList.addAll(tasks);

      emit(HomeSuccess(tasks: tasks, message: 'Task created successfully'));
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
    emit(HomeSuccess(tasks: _tasksList));
  }

  Future<void> _showDeleteTaskBottomSheet(
    HomeShowDeleteTaskBottomSheet event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeDeleteTaskBottomSheet(event.taskId));
    emit(HomeSuccess(tasks: _tasksList));
  }

  Future<void> _onConfirmDeleteTask(
    HomeConfirmDeleteTask event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      await _supabaseService.deleteTask(event.taskId);

      final tasks = await _supabaseService.getUserTasks();

      _tasksList.clear();
      _tasksList.addAll(tasks);

      emit(HomeSuccess(tasks: tasks, message: 'Task deleted successfully'));
    } on Exception catch (e) {
      if (e is AppException) {
        emit(HomeError(e.userFriendlyMessage));
      } else {
        emit(HomeError('Error deleting task'));
      }
    }
  }

  Future<void> _showEditTaskDialog(
    HomeShowEditTaskDialog event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeEditTaskDialog(event.task, _categoriesList));
    emit(HomeSuccess(tasks: _tasksList));
  }

  Future<void> _onEditTask(HomeEditTask event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    try {
      await _supabaseService.updateTask(event.task);

      final tasks = await _supabaseService.getUserTasks();

      _tasksList.clear();
      _tasksList.addAll(tasks);

      emit(HomeSuccess(tasks: tasks, message: 'Task updated successfully'));
    } on Exception catch (e) {
      if (e is AppException) {
        emit(HomeError(e.userFriendlyMessage));
      } else {
        emit(HomeError('Error updating task'));
      }
    }
  }

  FutureOr<void> _onUpdateCategories(
    HomeUpdateCategories event,
    Emitter<HomeState> emit,
  ) {
    _categoriesList.clear();
    _categoriesList.addAll(event.updatedCategories);
  }

  Future<void> _onLogoutUser(HomeLogout event, Emitter<HomeState> emit) async {
    try {
      await _supabaseService.logoutUser();

      emit(HomeGoBackToLogin());
    } on AppException catch (e) {
      emit(HomeError(e.userFriendlyMessage));
    }
  }

  Future<void> _onSearchTasks(
    HomeSearchTask event,
    Emitter<HomeState> emit,
  ) async {
    final query = event.query?.toLowerCase();

    if (query == null || query.isEmpty) {
      return emit(HomeSuccess(tasks: _tasksList));
    }

    final filteredTasks = _tasksList.where((task) {
      final title = task.title.toLowerCase();
      final description = task.description?.toLowerCase() ?? '';
      final categoryName = task.category?.name.toLowerCase() ?? '';
      final status = task.status.toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          categoryName.contains(query) ||
          status.toLowerCase().contains(query);
    }).toList();

    emit(HomeFilteredTasks(filteredTasks));
  }
}
