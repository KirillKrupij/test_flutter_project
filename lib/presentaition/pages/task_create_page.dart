import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TaskCreatePage extends StatefulWidget {
  const TaskCreatePage({super.key});

  @override
  State<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends State<TaskCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _allocatedTimeController = TextEditingController();

  DocumentReference? _selectedProject;
  DocumentReference? _selectedExecutor;
  DocumentReference? _selectedSetter;

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
              // Назад
              IconButton(
                onPressed: () => GoRouter.of(context).goNamed('home'),
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).iconTheme.color,
                ),
                tooltip: 'Назад',
              ),
              const SizedBox(height: 8),
              Text(
                'Новая задача',
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
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Название',
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Введите название'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Описание',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _allocatedTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Выделенное время (часы)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<QuerySnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('project')
                                .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }
                          final projects = snapshot.data!.docs;
                          return DropdownButtonFormField<DocumentReference>(
                            decoration: const InputDecoration(
                              labelText: 'Проект',
                            ),
                            items:
                                projects.map((doc) {
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
                            onChanged: (val) => _selectedProject = val,
                            validator:
                                (val) => val == null ? 'Выберите проект' : null,
                          );
                        },
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
                            children: [
                              DropdownButtonFormField<DocumentReference>(
                                decoration: const InputDecoration(
                                  labelText: 'Исполнитель',
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
                                              ).textTheme.bodyMedium,
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (val) => _selectedExecutor = val,
                                validator:
                                    (val) =>
                                        val == null
                                            ? 'Выберите исполнителя'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<DocumentReference>(
                                decoration: const InputDecoration(
                                  labelText: 'Постановщик',
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
                                              ).textTheme.bodyMedium,
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (val) => _selectedSetter = val,
                                validator:
                                    (val) =>
                                        val == null
                                            ? 'Выберите постановщика'
                                            : null,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createTask,
                          child: const Text('Создать'),
                        ),
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

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    final allocatedHours =
        double.tryParse(_allocatedTimeController.text.trim()) ?? 0;
    final allocatedSeconds = (allocatedHours * 3600).round();

    await FirebaseFirestore.instance.collection('task').add({
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'is_done': false,
      'allocated_time_sec': allocatedSeconds,
      'wasted_time_sec': 0,
      'created_at': DateTime.now(),
      'project': _selectedProject,
      'executor': _selectedExecutor,
      'setter': _selectedSetter,
    });

    if (context.mounted) {
      GoRouter.of(context).goNamed('home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Задача создана',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
  }
}
