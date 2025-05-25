import 'package:flutter/material.dart';
import 'features/app_bar/app_bar_title.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentaition/widgets/appbar.dart';
import 'app/app.dart';

// Future<void> addTestData() async {
//   try {
//     // Добавляем документ в коллекцию "test"
//     await FirebaseFirestore.instance.collection('tasks').add({
//       'name': 'Test Document',
//       'timestamp': DateTime.now(),
//     });
//     print('Data added to Firestore!');
//   } catch (e) {
//     print('Error adding data: $e');
//   }
// }

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await seedProjectsAndTasks();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppBarTitleNotifier()),
        ChangeNotifierProvider(create: (_) => ThemeModeNotifier()),
      ],
      child: App(),
    ),
  );
}
