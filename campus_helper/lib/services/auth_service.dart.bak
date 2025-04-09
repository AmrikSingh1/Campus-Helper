import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Google Sign In with PigeonUserDetails error handling
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Make sure we're logged out first to avoid cached issues
      await _googleSignIn.signOut();
      
      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // If sign-in is aborted by user
      if (googleUser == null) {
        print("Google Sign-In: User canceled the sign-in process");
        return null;
      }

      try {
        // Obtain auth details
        print("Google Sign-In: Getting authentication tokens for ${googleUser.email}");
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        if (googleAuth.accessToken == null) {
          print("Google Sign-In Error: Access token is null");
          throw FirebaseAuthException(
            code: 'invalid-credential',
            message: 'Google authentication failed: Missing access token'
          );
        }
        
        if (googleAuth.idToken == null) {
          print("Google Sign-In Error: ID token is null");
          throw FirebaseAuthException(
            code: 'invalid-credential',
            message: 'Google authentication failed: Missing ID token'
          );
        }
        
        // Create Firebase credential
        print("Google Sign-In: Creating Firebase credential");
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        // Sign in with Firebase
        print("Google Sign-In: Signing in to Firebase with Google credential");
        return await _auth.signInWithCredential(credential);
      } catch (e) {
        print("Google Sign-In Authentication Error: $e");
        
        if (e is PlatformException) {
          print("PlatformException during Google sign-in: ${e.code} - ${e.message}");
          
          // Handle specific platform exceptions
          if (e.code == 'channel-error' && e.message?.contains('PigeonUserDetails') == true) {
            print("Google Sign-In: PigeonUserDetails error detected");
            throw FirebaseAuthException(
              code: 'pigeonUserDetails-error',
              message: 'Error with Google Sign-In plugin. Try again or use another sign-in method.'
            );
          } else if (e.code == 'network_error') {
            throw FirebaseAuthException(
              code: 'network-request-failed',
              message: 'Network connection issue. Please check your internet connection.'
            );
          } else if (e.code == 'sign_in_failed') {
            throw FirebaseAuthException(
              code: 'sign_in_failed',
              message: 'Google sign-in process failed. Please try again.'
            );
          }
        }
        
        // If it's already a FirebaseAuthException, just rethrow it
        if (e is FirebaseAuthException) {
          rethrow;
        }
        
        // For any other type of error, wrap it in a FirebaseAuthException
        throw FirebaseAuthException(
          code: 'google-signin-error',
          message: 'Google sign-in failed: ${e.toString()}'
        );
      }
    } catch (e) {
      print("Exception during Google sign-in process: $e");
      
      // If it's already a FirebaseAuthException, just rethrow it
      if (e is FirebaseAuthException) {
        rethrow;
      }
      
      // For any other type of error, wrap it in a FirebaseAuthException
      throw FirebaseAuthException(
        code: 'google-signin-error',
        message: 'Google sign-in process failed: ${e.toString()}'
      );
    }
  }
} 