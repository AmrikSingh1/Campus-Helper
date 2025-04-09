import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';
import '../onboarding_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is authenticated, redirect to home screen
        if (snapshot.hasData && snapshot.data != null) {
          print('Auth state changed: User is signed in - ${snapshot.data?.email}');
          return const HomeScreen();
        }
        
        // If the user is not authenticated, show the onboarding screen
        print('Auth state changed: User is not signed in');
        return const OnboardingScreen();
      },
    );
  }
} 