//получение json с меню либо с сервера либо из файлов проекта
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class MenuLocalDataSource {
  final String serverUrl;
  final String localPath;

  MenuLocalDataSource({required this.serverUrl, required this.localPath});

  Future<List<dynamic>> getMenuItems() async {
    try {
      // Пытаемся получить данные с сервера
      final response = await http.post(Uri.parse(serverUrl));
      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        return jsonMap['menuItems'];
      } else {
        throw Exception('Failed to load data from server');
      }
    } catch (e) {
      // Если сервер недоступен, загружаем данные из локального файла
      final jsonString = await rootBundle.loadString(localPath);
      final jsonMap = json.decode(jsonString);
      return jsonMap['menuItems'];
    }
  }
}