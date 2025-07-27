import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseServiceProtocol {
  Future<void> initialize();
}

class SupabaseService extends SupabaseServiceProtocol {
  @override
  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://myzavtpabiqbhtztvwsi.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im15emF2dHBhYmlxYmh0enR2d3NpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1ODUzMDksImV4cCI6MjA2OTE2MTMwOX0.1g40at9Sresg09oQCWx241WMc5bUfG02ZTdB_MtIBZU',
    );
  }
}
