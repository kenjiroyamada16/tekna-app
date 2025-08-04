import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/domain/app_exception.dart';
import '../../data/entities/task.dart';
import '../../data/entities/task_category.dart';
import '../../shared/enum/task_status.dart';

abstract class SupabaseServiceProtocol {
  User? get user;
  Future<Session?> get currentSession;

  Future<void> initialize();
  Future<void> registerAccountEmailPassword({
    required String email,
    required String password,
  });
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<List<Task>> getUserTasks();
  Future<void> createTask(Task newTask);
  Future<void> deleteTask(int taskId);
  Future<void> updateTask(Task updatedTask);
  Future<List<TaskCategory>> getUserCategories();
}

class SupabaseService extends SupabaseServiceProtocol {
  late final SupabaseClient _client;

  @override
  User? get user => _client.auth.currentSession?.user;

  @override
  Future<Session?> get currentSession async => _client.auth.currentSession;

  @override
  Future<void> initialize() async {
    final supabase = await Supabase.initialize(
      url: 'https://myzavtpabiqbhtztvwsi.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im15emF2dHBhYmlxYmh0enR2d3NpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1ODUzMDksImV4cCI6MjA2OTE2MTMwOX0.1g40at9Sresg09oQCWx241WMc5bUfG02ZTdB_MtIBZU',
    );

    _client = supabase.client;
  }

  @override
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw AppException(
          userFriendlyMessage: 'There was an error with the request',
        );
      }
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          error: e,
          userFriendlyMessage: 'There was an error with the request',
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> registerAccountEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AppException(
          userFriendlyMessage: 'There was an error with the request',
        );
      }
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          error: e,
          userFriendlyMessage: 'There was an error with the request',
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<List<Task>> getUserTasks() async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    try {
      final response = await _client
          .from('tasks')
          .select('*, category:categories(id,name), media(*)')
          .eq('user_id', user?.id ?? -1)
          .order('created_at', ascending: false);

      final tasksList = response.map((map) => Task.fromJson(map)).toList();
      tasksList.sort((a, b) {
        final aStatus = TaskStatus.values
            .where((status) => status.label == a.status)
            .firstOrNull;
        final bStatus = TaskStatus.values
            .where((status) => status.label == b.status)
            .firstOrNull;

        return aStatus?.index.compareTo(bStatus?.index ?? 0) ?? 0;
      });

      return tasksList;
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          error: e,
          userFriendlyMessage: 'There was an error with the request',
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> createTask(Task newTask) async {
    try {
      if (user == null) {
        throw AppException(userFriendlyMessage: 'User not authenticated');
      }

      final taskMap = newTask.toJson();
      taskMap['user_id'] = user?.id;

      await _client.from('tasks').insert(taskMap);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Error creating task'),
        stackTrace,
      );
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    try {
      await _client.from('tasks').delete().eq('id', taskId);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Error deleting task'),
        stackTrace,
      );
    }
  }

  @override
  Future<void> updateTask(Task updatedTask) async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    try {
      final taskMap = updatedTask.toJson();
      taskMap['user_id'] = user?.id;
      taskMap['id'] = updatedTask.id;

      await _client.from('tasks').update(taskMap).eq('id', updatedTask.id);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Error updating task'),
        stackTrace,
      );
    }
  }

  @override
  Future<List<TaskCategory>> getUserCategories() async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    try {
      final response = await _client
          .from('categories')
          .select('id, name')
          .eq('user_id', user?.id ?? -1);
      final categories = response.map((json) {
        return TaskCategory.fromJson(json);
      }).toList();

      categories.sort((a, b) => a.name.compareTo(b.name));

      return categories;
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          error: e,
          userFriendlyMessage: 'Error fetching categories',
        ),
        stackTrace,
      );
    }
  }
}
