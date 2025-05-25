// файл приложения
import 'package:flutter/material.dart';
import '../presentaition/bloc/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/repositories/user_repository.dart';
import '../data/repositories/firebase_auth_repository.dart';
import '../data/datasources/firebase_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentaition/widgets/appbar.dart';
import 'package:provider/provider.dart';

import 'app_router.dart';
import 'app_styles.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  final AuthRepository authRepository = FirebaseAuthRepository(
    FirebaseDataSource(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router, // Используем маршрутизатор из `app_router.dart`
      title: 'EffortFlow',
      theme: AppStyles.lightTheme,
      darkTheme: AppStyles.darkTheme,
      themeMode: Provider.of<ThemeModeNotifier>(context).mode,
    );
  }
}
