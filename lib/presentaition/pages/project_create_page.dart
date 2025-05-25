import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectCreatePage extends StatefulWidget {
  const ProjectCreatePage({super.key});

  @override
  State<ProjectCreatePage> createState() => _ProjectCreatePageState();
}

class _ProjectCreatePageState extends State<ProjectCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DocumentReference? _selectedManager;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).iconTheme.color,
                ),
                tooltip: 'Назад',
                onPressed: () => GoRouter.of(context).goNamed('projects'),
              ),
              const SizedBox(height: 8),
              Text(
                'Создать проект',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Название проекта',
                        ),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
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

                          return DropdownButtonFormField<DocumentReference>(
                            decoration: const InputDecoration(
                              labelText: 'Руководитель',
                            ),
                            value: _selectedManager,
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
                            onChanged: (val) => _selectedManager = val,
                            validator:
                                (val) =>
                                    val == null
                                        ? 'Выберите руководителя'
                                        : null,
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
                            onPressed: _createProject,
                            child: const Text('Создать проект'),
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

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.collection('project').add({
        'name': _nameController.text.trim(),
        'manager': _selectedManager,
        'created_at': DateTime.now(),
      });

      if (context.mounted) {
        GoRouter.of(context).goNamed('projects');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Проект успешно создан',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка: $e',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
}
