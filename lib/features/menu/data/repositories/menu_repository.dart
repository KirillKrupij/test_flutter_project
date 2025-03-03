//репозиторий для получения json и преобразования его в модели
import '../datasources/local_data_source.dart';
import '../models/menu_item_model.dart';
import '../models/menu_section_model.dart';

class MenuDataRepository {
  final MenuLocalDataSource menuLocalDataSource;

  MenuDataRepository({required this.menuLocalDataSource});

  Future<List<dynamic>> getMenuData() async {
    try {
      // Получаем сырые данные из локального источника
      final rawMenuItems = await menuLocalDataSource.getMenuItems();

      // Преобразуем сырые данные в список моделей
      final parsedMenuItems = rawMenuItems.map((item) {
        if (item.containsKey('section')) {
          // Если элемент содержит ключ 'section', это раздел
          return MenuSectionModel.fromJson(item);
        } else {
          // Иначе это элемент меню
          return MenuItemModel.fromJson(item);
        }
      }).toList();

      return parsedMenuItems;
    } catch (e) {
      // Обработка ошибок
      throw Exception('Ошибка при загрузке данных меню: $e');
    }
  }
}