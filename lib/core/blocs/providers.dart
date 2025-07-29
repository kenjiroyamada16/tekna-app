import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_bloc.dart';
import 'login_bloc.dart';
import 'register_account_bloc.dart';
import 'splash_bloc.dart';

final List<BlocProvider> blocProviders = [
  BlocProvider<SplashBloc>(create: (_) => SplashBloc()),
  BlocProvider<LoginBloc>(create: (_) => LoginBloc()),
  BlocProvider<HomeBloc>(create: (_) => HomeBloc()),
  BlocProvider<RegisterAccountBloc>(create: (_) => RegisterAccountBloc()),
];
