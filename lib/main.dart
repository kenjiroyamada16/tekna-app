import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/blocs/providers.dart';
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
    return MultiBlocProvider(
      providers: blocProviders,
      child: MaterialApp(
        title: 'Tekna App',
        theme: AppTheme.defaultTheme,
        routes: AppRouter.routes,
        initialRoute: AppRouter.splashRoute,
      ),
    );
  }
}
