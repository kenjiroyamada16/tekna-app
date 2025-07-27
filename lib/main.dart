import 'package:flutter/material.dart';

import 'core/di/injector.dart';
import 'core/router/app_router.dart';
import 'style/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeAppDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tekna App',
      theme: AppTheme.defaultTheme,
      routes: AppRouter.routes,
      initialRoute: AppRouter.splashRoute,
    );
  }
}
