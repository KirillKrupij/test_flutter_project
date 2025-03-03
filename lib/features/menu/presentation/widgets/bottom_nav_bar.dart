//нижнее меню и логика его переключения
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0; // По умолчанию активна первая вкладка

  int _getSelectedIndexFromRoute(String location) {
    if (location == '/') return 0; // Главная страница — активна кнопка "Home"
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/patients')) return 2;
    if (location.startsWith('/records')) return 3;
    if (location.startsWith('/events')) return 4;
    return 0; // По умолчанию активна кнопка "Home"
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final routeState = GoRouterState.of(context);
    final location = routeState.uri.toString(); // Получаем текущий маршрут
    setState(() {
      _selectedIndex = _getSelectedIndexFromRoute(location);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Theme.of(context).primaryColor,
      selectedLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
      selectedIconTheme: IconThemeData(
        size: 24,
        color: Theme.of(context).primaryColor,
      ),
      unselectedItemColor: Colors.black54,
      unselectedLabelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
      unselectedIconTheme: IconThemeData(
        size: 22,
        color: Colors.black54,
      ),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'), // Кнопка "Home"
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Календарь'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Пациенты'),
        BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Записи'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'События'),
      ],
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        switch (index) {
          case 0:
            context.go('/'); // Переход на главную страницу
            break;
          case 1:
            context.goNamed('CalendarPage');
            break;
          case 2:
            context.goNamed('PatientsPage');
            break;
          case 3:
            context.goNamed('RecordsPage');
            break;
          case 4:
            context.goNamed('EventsPage');
            break;
        }
      },
    );
  }
}