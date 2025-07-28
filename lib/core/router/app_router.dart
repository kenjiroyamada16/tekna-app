import 'package:flutter/material.dart';

import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_account_page.dart';
import '../../presentation/pages/splash_page.dart';

class AppRouter {
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String registerAccountroute = '/register_account';

  static final Map<String, Widget Function(BuildContext)> routes = {
    splashRoute: (_) => const SplashPage(),
    loginRoute: (_) => const LoginPage(),
    homeRoute: (_) => const HomePage(),
    registerAccountroute: (_) => const RegisterAccountPage(),
  };
}
