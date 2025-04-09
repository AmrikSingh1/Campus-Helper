#!/bin/bash

cat > lib/services/auth_service.dart << 'EOF'
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  clientId: kIsWeb ? '829155372633-41e00fk0mvd6re3a2e35n64c6o0sp7ks.apps.googleusercontent.com' : null,
);

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      
      // User canceled the sign-in flow
      if (gUser == null) {
        print('Google Sign-In was canceled by user');
        return null;
      }
      
      // Obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      
      // Create a new credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      
      // Finally, sign in
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      _handleSignInError(e);
      return null;
    }
  }
  
  void _handleSignInError(dynamic error) {
    print('Error during Google Sign-In: $error');
    
    if (error is PlatformException) {
      if (error.code == 'network_error') {
        print('Network error occurred. Check your internet connection.');
      } else if (error.code == 'sign_in_canceled') {
        print('Sign-in was canceled');
      } else {
        print('Platform Exception: ${error.message}');
      }
    } else if (error is FirebaseAuthException) {
      print('Firebase Auth Exception: ${error.code} - ${error.message}');
    } else {
      print('Unexpected error: $error');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
EOF

echo "Updated auth_service.dart with fixed implementation."
