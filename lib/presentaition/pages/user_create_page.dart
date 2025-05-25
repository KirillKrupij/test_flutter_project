import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserCreatePage extends StatefulWidget {
  const UserCreatePage({super.key});

  @override
  State<UserCreatePage> createState() => _UserCreatePageState();
}

class _UserCreatePageState extends State<UserCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _salaryHourController = TextEditingController();
  final _salaryMonthController = TextEditingController();

  bool _isAdmin = false;
  bool _isManager = false;
  DocumentReference? _selectedDepartment;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => GoRouter.of(context).goNamed('employees'),
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).iconTheme.color,
                ),
                tooltip: 'Назад',
              ),
              const SizedBox(height: 8),
              Text(
                'Создать пользователя',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _fullnameController,
                        decoration: const InputDecoration(labelText: 'ФИО'),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Введите имя'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator:
                            (value) =>
                                value == null || !value.contains('@')
                                    ? 'Введите email'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Пароль'),
                        obscureText: true,
                        validator:
                            (value) =>
                                value != null && value.length < 6
                                    ? 'Минимум 6 символов'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _salaryHourController,
                        decoration: const InputDecoration(
                          labelText: 'Ставка в час (₽)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _salaryMonthController,
                        decoration: const InputDecoration(
                          labelText: 'Оклад в месяц (₽)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<QuerySnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('department')
                                .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }
                          final departments = snapshot.data!.docs;
                          return DropdownButtonFormField<DocumentReference>(
                            decoration: const InputDecoration(
                              labelText: 'Отдел',
                            ),
                            items:
                                departments.map((doc) {
                                  return DropdownMenuItem(
                                    value: doc.reference,
                                    child: Text(
                                      doc['name'],
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (val) => _selectedDepartment = val,
                            validator:
                                (val) => val == null ? 'Выберите отдел' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: Text(
                          'Менеджер',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: _isManager,
                        onChanged:
                            (val) => setState(() => _isManager = val ?? false),
                      ),
                      CheckboxListTile(
                        title: Text(
                          'Администратор',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: _isAdmin,
                        onChanged:
                            (val) => setState(() => _isAdmin = val ?? false),
                      ),
                      const SizedBox(height: 20),
                      _loading
                          ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                          : ElevatedButton(
                            onPressed: _createUser,
                            child: const Text('Создать пользователя'),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1. Создаём в Firebase Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Добавляем в Firestore
      await FirebaseFirestore.instance
          .collection('user')
          .doc(cred.user!.uid)
          .set({
            'fullname': _fullnameController.text.trim(),
            'email': _emailController.text.trim(),
            'is_admin': _isAdmin,
            'is_manager': _isManager,
            'salary_per_hour':
                double.tryParse(_salaryHourController.text.trim()) ?? 0,
            'salary_per_month':
                double.tryParse(_salaryMonthController.text.trim()) ?? 0,
            'department': _selectedDepartment,
          });

      if (context.mounted) {
        GoRouter.of(context).goNamed('employees');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Пользователь успешно создан',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ошибка: $e',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }
}
