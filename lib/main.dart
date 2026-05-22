import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/providers/student_provider.dart';
import 'core/providers/faculty_provider.dart';
import 'core/providers/admin_provider.dart';
import 'core/providers/battle_provider.dart';
import 'features/auth/screens/role_selection_screen.dart';
import 'features/dashboard/screens/student_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => FacultyProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => BattleProvider()),
      ],
      child: const NeuroLearnAI(),
    ),
  );
}

class NeuroLearnAI extends StatelessWidget {
  const NeuroLearnAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeuroLearn AI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const RoleSelectionScreen(),
        '/dashboard': (_) => const StudentDashboard(),
      },
    );
  }
}