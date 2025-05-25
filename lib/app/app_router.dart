//файл для управления путями в приложении

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Импортируем страницы

import '../presentaition/widgets/menu/menu.dart';
import '../features/app_bar/app_bar_title.dart';
import '../presentaition/pages/departments.dart';
import '../presentaition/pages/department_create_page.dart';
import '../presentaition/pages/department_detail_page.dart';
import '../presentaition/pages/projects.dart';
import '../presentaition/pages/project_create_page.dart';
import '../presentaition/pages/project_detail_page.dart';
import '../presentaition/pages/login_page.dart';
import '../presentaition/widgets/appbar.dart';

import '../presentaition/pages/tasks.dart';
import '../presentaition/pages/task_create_page.dart';
import '../presentaition/pages/task_detail_page.dart';
import '../presentaition/pages/empoyees.dart';
import '../presentaition/pages/user_create_page.dart';
import '../presentaition/pages/user_detail_page.dart';
import '../presentaition/pages/perfomance.dart';

final GoRouter router = GoRouter(
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final loggingIn = state.uri.toString() == '/login';

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          appBar: CustomAppBar(),
          body: SafeArea(child: child),
          drawer: getSideMenu(context),
          bottomNavigationBar: getNavBar(context),
        );
      },
      routes: [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (context, state) {
            Provider.of<AppBarTitleNotifier>(
              context,
              listen: false,
            ).setTitle('Задачи');
            return const TaskListPage();
          },
        ),
        GoRoute(
          path: '/tasks/create',
          name: 'createTask',
          builder: (context, state) => const TaskCreatePage(),
        ),
        GoRoute(
          path: '/task/:id',
          name: 'taskDetail',
          builder: (context, state) {
            final taskId = state.pathParameters['id']!;
            return TaskDetailPage(taskId: taskId);
          },
        ),
        GoRoute(
          name: 'projects',
          path: '/projects',
          builder: (context, state) {
            Provider.of<AppBarTitleNotifier>(
              context,
              listen: false,
            ).setTitle('Проекты');
            return const ProjectListPage();
          },
        ),
        GoRoute(
          path: '/projects/create',
          name: 'createProject',
          builder: (context, state) => const ProjectCreatePage(),
        ),
        GoRoute(
          path: '/project/:id',
          name: 'createDetail',
          builder: (context, state) {
            final projectId = state.pathParameters['id']!;
            return ProjectDetailPage(projectId: projectId);
          },
        ),
        GoRoute(
          name: 'employees',
          path: '/employees',
          builder: (context, state) {
            Provider.of<AppBarTitleNotifier>(
              context,
              listen: false,
            ).setTitle('Сотрудники');
            return const UserListPage();
          },
        ),
        GoRoute(
          path: '/employees/create',
          name: 'createUser',
          builder: (context, state) => const UserCreatePage(),
        ),
        GoRoute(
          path: '/employees/:id',
          name: 'userDetail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return UserDetailPage(userId: id);
          },
        ),
        GoRoute(
          name: 'departments',
          path: '/departments',
          builder: (context, state) {
            Provider.of<AppBarTitleNotifier>(
              context,
              listen: false,
            ).setTitle('Отделы');
            return const DepartmentListPage();
          },
        ),
        GoRoute(
          path: '/departments/create',
          name: 'createDepartment',
          builder: (context, state) => const DepartmentCreatePage(),
        ),
        GoRoute(
          path: '/perfomance',
          name: 'perfomance',
          builder: (context, state) {
            Provider.of<AppBarTitleNotifier>(
              context,
              listen: false,
            ).setTitle('Расчет зарплаты');
            return const SalaryReportPage();
          },
        ),
        GoRoute(
          path: '/department/:id',
          name: 'departmentDetail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DepartmentDetailPage(departmentId: id);
          },
        ),
      ],
    ),
  ],
);
