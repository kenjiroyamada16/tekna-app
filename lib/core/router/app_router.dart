import 'package:flutter/material.dart';

import '../../presentation/pages/splash_page.dart';

class AppRouter {
  static const String splashRoute = '/';

  static final Map<String, Widget Function(BuildContext)> routes = {
    splashRoute: (context) => const SplashPage(),
  };
}
