import 'package:flutter/material.dart';
import 'features/app_bar/app_bar_title.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => AppBarTitleNotifier(),
      child: const App(),
    ),);
}