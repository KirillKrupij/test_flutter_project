// динамическая замена тайтлов в аппбаре
import 'package:flutter/material.dart';

class AppBarTitleNotifier extends ChangeNotifier {
  String _title = 'Home';

  String get title => _title;

  void setTitle(String newTitle) {
    if (_title != newTitle) {
      _title = newTitle;
      notifyListeners(); // Уведомляем слушателей об изменении
    }
  }
}