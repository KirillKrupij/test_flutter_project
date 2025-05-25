import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;
  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final _commentController = TextEditingController();
  final _timeController = TextEditingController();

  late DocumentReference taskRef;

  @override
  void initState() {
    super.initState();
    taskRef = FirebaseFirestore.instance.collection('task').doc(widget.taskId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: taskRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }
        if (!snapshot.data!.exists) {
          return Center(
            child: Text(
              'Задача не найдена',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        final task = snapshot.data!;
        final data = task.data() as Map<String, dynamic>;

        final title = data['title'] ?? '';
        final desc = data['description'] ?? '';
        final isDone = data['is_done'] ?? false;
        final createdAt = (data['created_at'] as Timestamp).toDate();
        final allocated = data['allocated_time_sec'] ?? 0;
        final wasted = data['wasted_time_sec'] ?? 0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  // Назад
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => GoRouter.of(context).goNamed('home'),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      tooltip: 'Назад',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(
                        isDone ? Icons.check_circle : Icons.access_time,
                        color:
                            isDone
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Создано: ${DateFormat.yMMMMd().format(createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(desc, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Text(
                    'Выделено: ${(allocated / 3600).toStringAsFixed(1)} ч',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Потрачено: ${(wasted / 3600).toStringAsFixed(1)} ч',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Divider(height: 32),

                  // Добавление времени
                  Text(
                    'Добавить время (в часах):',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _timeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Например, 1.5',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final hours =
                              double.tryParse(_timeController.text.trim()) ?? 0;
                          final seconds = (hours * 3600).round();
                          await taskRef.update({
                            'wasted_time_sec': wasted + seconds,
                          });
                          _timeController.clear();
                        },
                        child: const Text('Добавить'),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Комментарии
                  Text(
                    'Добавить комментарий:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Комментарий',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final content = _commentController.text.trim();
                          if (content.isEmpty) return;
                          await FirebaseFirestore.instance
                              .collection('comment')
                              .add({
                                'content': content,
                                'created_at': DateTime.now(),
                                'task': taskRef,
                                'author':
                                    null, // можно привязать если будет auth
                              });
                          _commentController.clear();
                        },
                        child: const Text('Отправить'),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('comment')
                            .where('task', isEqualTo: taskRef)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }
                      final comments = snapshot.data!.docs;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            comments.map((doc) {
                              final c = doc.data() as Map<String, dynamic>;
                              final text = c['content'] ?? '';
                              final time =
                                  (c['created_at'] as Timestamp).toDate();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      text,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      DateFormat('dd.MM.y HH:mm').format(time),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                  const Divider(height: 32),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Отметить выполненной'),
                        onPressed:
                            isDone
                                ? null
                                : () async {
                                  await taskRef.update({'is_done': true});
                                },
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Удалить'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: Text(
                                    'Удалить задачу?',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                  ),
                                  content: Text(
                                    'Это действие нельзя отменить.',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
                                      child: Text(
                                        'Отмена',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(
                                        'Удалить',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true) {
                            await taskRef.delete();
                            if (context.mounted) {
                              GoRouter.of(context).goNamed('home');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
