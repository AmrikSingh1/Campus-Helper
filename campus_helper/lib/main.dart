import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('Firebase: Starting initialization with options');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase: Successfully initialized with options');
  } catch (e) {
    print('Firebase: Error during initialization: $e');
    // Continue the app even if Firebase fails - just for debugging purposes
  }
  
  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Helper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Show splash screen initially, it will then navigate to AuthWrapper
      home: const SplashScreen(),
    );
  }
}
