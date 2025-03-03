//файл для управления путями в приложении

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Импортируем страницы
import '../features/pages/calendar_page.dart';
import '../features/pages/patients_page.dart';
import '../features/pages/records_page.dart';
import '../features/pages/events_page.dart';
import '../features/pages/home_page.dart';
import '../features/menu/presentation/menu.dart';
import '../features/app_bar/app_bar_title.dart';

final GoRouter router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          appBar: AppBar(
            title: Consumer<AppBarTitleNotifier>(
              builder: (context, appBarTitleNotifier, _) {
                return Text(appBarTitleNotifier.title);
              },
            ),
          ),
          body: SafeArea(
            child: child,
          ),
          drawer: getSideMenu(context),
          bottomNavigationBar: getNavBar(context),
        );
      },
      routes: [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (context, state) {
            // Устанавливаем заголовок при построении страницы
            Provider.of<AppBarTitleNotifier>(context, listen: false)
                .setTitle('Главная');
            return const HomePage();
          },
        ),
        GoRoute(
          name: 'CalendarPage',
          path: '/calendar',
          builder: (context, state) {
            Provider.of<AppBarTitleNotifier>(context, listen: false)
                .setTitle('Календарь');
            return CalendarPage();
          },
        ),
        GoRoute(
          name: 'PatientsPage',
          path: '/patients',
          builder: (context, state) {
            Provider.of<AppBarTitleNotifier>(context, listen: false)
                .setTitle('Пациенты');
            return const PatientsPage();
          },
        ),
        GoRoute(
          name: 'RecordsPage',
          path: '/records',
          builder: (context, state) {
            Provider.of<AppBarTitleNotifier>(context, listen: false)
                .setTitle('Записи');
            return const RecordsPage();
          },
        ),
        GoRoute(
          name: 'EventsPage',
          path: '/events',
          builder: (context, state) {
            Provider.of<AppBarTitleNotifier>(context, listen: false)
                .setTitle('События');
            return const EventsPage();
          },
        ),
      ],
    ),
  ],
);