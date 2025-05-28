import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:talentloop/navigation_screens/main_navigation_screen.dart';
import 'package:talentloop/start_app_screens/splash_screen.dart';
import 'package:talentloop/services/auth_service.dart';
import 'services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
/*****
  final authService = AuthService();

  try {
    await authService.loginUser(email: 'aa@gmail.com', password: '1234321');
    print("✅ Login successful");
  } catch (e) {
    print("❌ Login failed: $e");
  }
******/
  runApp(const TalentLoopApp());
}

class TalentLoopApp extends StatelessWidget {
  const TalentLoopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TalentLoop',
      debugShowCheckedModeBanner: false, // Removed debug banner
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
