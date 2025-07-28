import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseServiceProtocol {
  User? get user;

  Future<void> initialize();
  Future<Session?> get currentSession;
  Future<void> registerAccountEmailPassword({required String email, required String password});
  Future<void> loginWithEmailAndPassword({required String email, required String password});
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
    final response = await _client.auth.signInWithPassword(email: email, password: password);

    if (response.session == null) throw Exception('Houve um erro na requisição');
  }

  @override
  Future<void> registerAccountEmailPassword({required String email, required String password}) async {
    final response = await _client.auth.signUp(email: email, password: password);

    if (response.user == null) throw Exception('Houve um erro na requisição');
  }
}
