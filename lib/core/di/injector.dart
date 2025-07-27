import 'package:get_it/get_it.dart';

import 'modules/core_module.dart';

abstract class AppModule {
  void registerDependencies();
}

class ServiceLocator {
  ServiceLocator._();

  static final _getIt = GetIt.instance;

  static T get<T extends Object>({dynamic param, String? instanceName}) {
    return _getIt.get<T>(param1: param, instanceName: instanceName);
  }

  static void registerSingleton<T extends Object>(T instance) {
    if (_getIt.isRegistered<T>()) return;

    _getIt.registerSingleton<T>(instance);
  }

  static void registerLazySingleton<T extends Object>(T Function() constructor) {
    if (_getIt.isRegistered<T>()) return;

    _getIt.registerLazySingleton<T>(constructor);
  }

  static void registerFactory<T extends Object>(T Function() constructor, {String? instanceName}) {
    if (_getIt.isRegistered<T>()) return;

    _getIt.registerFactory<T>(
      constructor,
      instanceName: instanceName,
    );
  }

  static void registerFactoryParam<T extends Object, P1>(T Function(P1) constructor, {String? instanceName}) {
    if (_getIt.isRegistered<T>()) return;

    _getIt.registerFactoryParam<T, P1, void>(
      (param, _) => constructor(param),
      instanceName: instanceName,
    );
  }
}

Future<void> initializeAppDependencies() async {
  final appModules = <AppModule>[
    CoreModule(),
  ];

  for (final module in appModules) {
    module.registerDependencies();
  }
}
