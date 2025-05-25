import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DepartmentCreatePage extends StatefulWidget {
  const DepartmentCreatePage({super.key});

  @override
  State<DepartmentCreatePage> createState() => _DepartmentCreatePageState();
}

class _DepartmentCreatePageState extends State<DepartmentCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  DocumentReference? _selectedSupervisor;
  final Set<DocumentReference> _selectedEmployees = {};

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
                onPressed: () => GoRouter.of(context).goNamed('departments'),
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Назад',
              ),
              const SizedBox(height: 8),
              Text(
                'Создать отдел',
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
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Название отдела',
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Введите название'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<QuerySnapshot>(
                        future:
                            FirebaseFirestore.instance.collection('user').get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }
                          final users = snapshot.data!.docs;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<DocumentReference>(
                                decoration: const InputDecoration(
                                  labelText: 'Руководитель',
                                ),
                                items:
                                    users.map((doc) {
                                      return DropdownMenuItem(
                                        value: doc.reference,
                                        child: Text(
                                          doc['fullname'],
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyLarge,
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (val) => _selectedSupervisor = val,
                                validator:
                                    (val) =>
                                        val == null
                                            ? 'Выберите руководителя'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Сотрудники:',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              ...users.map((doc) {
                                final userRef = doc.reference;
                                final name = doc['fullname'];
                                return CheckboxListTile(
                                  value: _selectedEmployees.contains(userRef),
                                  title: Text(
                                    name,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedEmployees.add(userRef);
                                      } else {
                                        _selectedEmployees.remove(userRef);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _loading
                          ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                          : ElevatedButton(
                            onPressed: _createDepartment,
                            child: const Text('Создать отдел'),
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

  Future<void> _createDepartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1. Создать отдел
      final deptRef = await FirebaseFirestore.instance
          .collection('department')
          .add({
            'name': _nameController.text.trim(),
            'supervisor': _selectedSupervisor,
          });

      // 2. Назначить сотрудникам этот отдел
      for (final userRef in _selectedEmployees) {
        await userRef.update({'department': deptRef});
      }

      if (context.mounted) {
        GoRouter.of(context).goNamed('departments');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Отдел успешно создан',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ошибка: ${e.toString()}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }
}
