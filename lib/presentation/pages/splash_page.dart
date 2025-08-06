import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/splash_bloc.dart';
import '../../core/router/app_router.dart';
import '../../style/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SplashBloc>();
    _bloc.add(SplashStarted());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<SplashBloc, SplashState>(
            listener: (_, state) {
              if (state is SplashSuccess) _sessionNavigate(state);
            },
            builder: (_, state) {
              if (state is SplashLoading || state is SplashSuccess) {
                return Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'Tekna Tasks',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Center(
                child: Text('Tekna Tasks', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ),
    );
  }

  void _sessionNavigate(SplashSuccess state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, state.hasSession ? AppRouter.homeRoute : AppRouter.loginRoute);
    });
  }
}
