import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/domain/app_exception.dart';
import '../../data/entities/task.dart';

abstract class SupabaseServiceProtocol {
  User? get user;
  Future<Session?> get currentSession;

  Future<void> initialize();
  Future<void> registerAccountEmailPassword({required String email, required String password});
  Future<void> loginWithEmailAndPassword({required String email, required String password});

  Future<List<Task>> getUserTasks();
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
  Future<void> loginWithEmailAndPassword({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(email: email, password: password);

      if (response.session == null) {
        throw AppException(userFriendlyMessage: 'Houve um erro na requisição');
      }
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Houve um erro na requisição'),
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
      final response = await _client.auth.signUp(email: email, password: password);

      if (response.user == null) {
        throw AppException(userFriendlyMessage: 'Houve um erro na requisição');
      }
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Houve um erro na requisição'),
        stackTrace,
      );
    }
  }

  @override
  Future<List<Task>> getUserTasks() async {
    if (user == null) throw AppException(userFriendlyMessage: 'Usuário não autenticado');

    try {
      final response = await _client
          .from('tasks')
          .select('*, category:categories(name), media(*)')
          .eq('user_id', user?.id ?? -1)
          .order('created_at', ascending: false);

      return response.map((map) => Task.fromJson(map)).toList();
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Houve um erro na requisição'),
        stackTrace,
      );
    }
  }
}
