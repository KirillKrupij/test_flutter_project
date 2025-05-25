import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String _filter = 'all'; // all | open | done
  late String currentUserId;
  Map<String, dynamic>? currentUserData;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('user')
            .doc(currentUserId)
            .get();
    setState(() {
      currentUserData = snapshot.data();
      isLoadingUser = false;
    });
  }

  Future<bool> _canViewTask(DocumentSnapshot task) async {
    final executorRef = task['executor'] as DocumentReference?;
    if (executorRef == null) return false;
    final executorSnap = await executorRef.get();
    final executorData = executorSnap.data() as Map<String, dynamic>?;
    if (executorData == null) return false;

    final executorId = executorRef.id;
    final executorDept = executorData['department'];

    final isAdmin = currentUserData!['is_admin'] == true;
    final isManager = currentUserData!['is_manager'] == true;
    final userDepartment = currentUserData!['department'];

    return isAdmin ||
        (isManager && executorDept != null && executorDept == userDepartment) ||
        executorId == currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser || currentUserData == null) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Все задачи',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _filter,
                    items: [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text(
                          'Все',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'open',
                        child: Text(
                          'Открытые',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'done',
                        child: Text(
                          'Завершённые',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filter = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('task')
                        .orderBy('created_at', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Ошибка при загрузке задач',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }

                  final rawTasks = snapshot.data!.docs;

                  return FutureBuilder<List<DocumentSnapshot>>(
                    future: Future.wait(
                      rawTasks
                          .where((doc) {
                            final isDone = doc['is_done'] ?? false;
                            if (_filter == 'done' && !isDone) return false;
                            if (_filter == 'open' && isDone) return false;
                            return true;
                          })
                          .map((doc) async {
                            return await _canViewTask(doc) ? doc : null;
                          }),
                    ).then(
                      (list) => list.whereType<DocumentSnapshot>().toList(),
                    ),
                    builder: (context, filteredSnap) {
                      if (!filteredSnap.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final tasks = filteredSnap.data!;

                      if (tasks.isEmpty) {
                        return Center(
                          child: Text(
                            'Задач нет для выбранного фильтра',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final title = task['title'] ?? '';
                          final isDone = task['is_done'] ?? false;
                          final allocated = task['allocated_time_sec'] ?? 0;
                          final wasted = task['wasted_time_sec'] ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  GoRouter.of(context).go('/task/${task.id}');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            isDone
                                                ? Icons.check_circle
                                                : Icons.access_time,
                                            color:
                                                isDone
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.secondary
                                                    : Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Выделено: ${(allocated / 3600).toStringAsFixed(1)} ч • Потрачено: ${(wasted / 3600).toStringAsFixed(1)} ч',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              GoRouter.of(context).goNamed('createTask');
            },
            child: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
            tooltip: 'Добавить задачу',
          ),
        ),
      ],
    );
  }
}
