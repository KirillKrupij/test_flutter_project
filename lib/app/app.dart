// файл приложения
import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_styles.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router, // Используем маршрутизатор из `app_router.dart`
      title: 'Ахуенное приложение =)',
      theme: AppStyles.appTheme,
    );
  }
}

