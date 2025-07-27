import '../../services/supabase_service.dart';
import '../injector.dart';

class CoreModule extends AppModule {
  @override
  void registerDependencies() {
    ServiceLocator.registerLazySingleton<SupabaseServiceProtocol>(() {
      return SupabaseService();
    });
  }
}
