import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SalaryReportPage extends StatefulWidget {
  const SalaryReportPage({super.key});

  @override
  State<SalaryReportPage> createState() => _SalaryReportPageState();
}

class _SalaryReportPageState extends State<SalaryReportPage> {
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
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

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser || currentUserData == null) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    final monthStart = Timestamp.fromDate(selectedMonth);
    final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    final monthEnd = Timestamp.fromDate(nextMonth);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Месяц:', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedMonth,
                    firstDate: DateTime(2022),
                    lastDate: DateTime.now(),
                    helpText: 'Выберите дату внутри нужного месяца',
                  );
                  if (picked != null) {
                    setState(() {
                      selectedMonth = DateTime(picked.year, picked.month);
                    });
                  }
                },
                child: Text(
                  DateFormat.yMMMM().format(selectedMonth),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('task')
                      .where('created_at', isGreaterThanOrEqualTo: monthStart)
                      .where('created_at', isLessThan: monthEnd)
                      .get(),
              builder: (context, taskSnap) {
                if (!taskSnap.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }

                final tasks = taskSnap.data!.docs;
                final usersMap = <String, Map<String, dynamic>>{};
                final userTaskMap =
                    <String, Map<String, Map<String, dynamic>>>{};

                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('user').get(),
                  builder: (context, userSnap) {
                    if (!userSnap.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }

                    final isAdmin = currentUserData!['is_admin'] == true;
                    final isManager = currentUserData!['is_manager'] == true;
                    final userDepartment = currentUserData!['department'];
                    final isDepartmentHead = userSnap.data!.docs.any(
                      (doc) =>
                          doc.id == currentUserId &&
                          doc['is_manager'] == true &&
                          (doc['department'] != null),
                    );

                    for (final user in userSnap.data!.docs) {
                      final userId = user.id;
                      final userDept = user['department'];

                      final canView =
                          isAdmin ||
                          (isManager &&
                              isDepartmentHead &&
                              userDept != null &&
                              userDept == userDepartment) ||
                          userId == currentUserId;

                      if (!canView) continue;

                      usersMap[userId] = {
                        'fullname': user['fullname'],
                        'salary_per_hour': user['salary_per_hour'] ?? 0.0,
                        'salary_per_month': user['salary_per_month'] ?? 0.0,
                      };
                      userTaskMap[userId] = {};
                    }

                    for (final task in tasks) {
                      final data = task.data() as Map<String, dynamic>;
                      final executorRef =
                          data['executor'] as DocumentReference?;
                      if (executorRef == null) continue;

                      final executorId = executorRef.id;
                      if (!userTaskMap.containsKey(executorId)) continue;

                      final allocated =
                          (data['allocated_time_sec'] ?? 0) / 3600.0;
                      final wasted = (data['wasted_time_sec'] ?? 0) / 3600.0;
                      final rate =
                          usersMap[executorId]?['salary_per_hour'] ?? 0.0;
                      final chargeable =
                          wasted > allocated ? allocated : wasted;
                      final cost = chargeable * rate;

                      userTaskMap[executorId]![task.id] = {
                        'title': data['title'] ?? 'Без названия',
                        'hours': wasted,
                        'cost': cost,
                      };
                    }

                    final taskIds = tasks.map((e) => e.id).toList();
                    final taskTitles =
                        tasks.map((e) => e['title'] ?? '—').toList();

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Text(
                              'Сотрудник',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          ...taskTitles.map(
                            (t) => DataColumn(
                              label: Text(
                                t,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Оклад',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Итого часов',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Итого ₽',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                        rows:
                            usersMap.entries.map((entry) {
                              final uid = entry.key;
                              final user = entry.value;
                              final userTasks = userTaskMap[uid]!;

                              double totalHours = 0;
                              double totalCost = 0;

                              final cells =
                                  taskIds.map((tid) {
                                    final t = userTasks[tid];
                                    if (t == null) {
                                      return DataCell(
                                        Text(
                                          '-',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                        ),
                                      );
                                    }
                                    totalHours += t['hours'];
                                    totalCost += t['cost'];
                                    return DataCell(
                                      Text(
                                        '${t['hours'].toStringAsFixed(1)} ч\n${t['cost'].toStringAsFixed(0)} ₽',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    );
                                  }).toList();

                              final fixedSalary =
                                  user['salary_per_month'] ?? 0.0;

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      user['fullname'] ?? '—',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  ...cells,
                                  DataCell(
                                    Text(
                                      '${fixedSalary.toStringAsFixed(0)} ₽',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${totalHours.toStringAsFixed(1)} ч',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${(totalCost + fixedSalary).toStringAsFixed(0)} ₽',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
