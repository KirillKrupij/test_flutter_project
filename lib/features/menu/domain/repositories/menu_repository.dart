//репозиторий для преобразования простых моделей в сущности, которые используются в для отрисовки меню
import 'package:flutter/material.dart';
import '../../../../domain/entities/menu_item_entity.dart';
import '../../../../domain/entities/menu_section_entity.dart';
import '../../data/repositories/menu_repository.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/menu_section_model.dart';

class MenuDomainRepository {
  final MenuDataRepository menuRepository;

  MenuDomainRepository({required this.menuRepository});

  Future<List<dynamic>> getMenuEntities() async {
    try {
      // Получаем список моделей из MenuRepository
      final menuModels = await menuRepository.getMenuData();

      // Преобразуем модели в сущности
      final menuEntities =
          menuModels.map((model) {
            if (model is MenuSectionModel) {
              // Если модель - раздел меню
              return MenuSectionEntity(section: model.section);
            } else if (model is MenuItemModel) {
              // Если модель - пункт меню
              return MenuItemEntity(
                icon: getIconFromName(
                  model.icon,
                ), // Преобразуем строку в IconData
                text: model.text,
                page: model.page,
              );
            } else {
              throw Exception('Неизвестный тип модели: $model');
            }
          }).toList();

      return menuEntities;
    } catch (e) {
      // Обработка ошибок
      throw Exception('Ошибка при получении сущностей меню: $e');
    }
  }

  // Маппинг строковых значений на иконки
  IconData getIconFromName(String iconName) {
    switch (iconName) {
      case 'event':
        return Icons.event;
      case 'person':
        return Icons.person;
      case 'note':
        return Icons.note;
      case 'medical_services':
        return Icons.medical_services;
      case 'visibility':
        return Icons.visibility;
      case 'analytics':
        return Icons.analytics;
      case 'receipt':
        return Icons.receipt;
      case 'money':
        return Icons.money;
      case 'sell':
        return Icons.sell;
      case 'report':
        return Icons.report;
      default:
        return Icons.help; // Значение по умолчанию
    }
  }
}
