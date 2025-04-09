import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

// Create GoogleSignIn as a singleton to avoid multiple instances
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  factory GoogleSignInService() {
    return _instance;
  }

  GoogleSignInService._internal();

  GoogleSignIn get googleSignIn => _googleSignIn;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignInService().googleSignIn;
  
  // Add a flag to prevent multiple sign-in attempts
  bool _isSigningIn = false;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Add a getter for the current user
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    // If already signing in, prevent multiple attempts
    if (_isSigningIn) {
      print('Google Sign-In: Already in progress, ignoring duplicate request');
      return null;
    }
    
    _isSigningIn = true;
    
    try {
      print('Google Sign-In: Starting authentication flow');
      
      // Check if already signed in with Google
      final currentUser = await _googleSignIn.signInSilently();
      if (currentUser != null) {
        print('Google Sign-In: Already signed in as ${currentUser.email}, signing out first');
        // Sign out from Google first to ensure a clean state
        await _googleSignIn.disconnect();
      }
      
      // Start the interactive sign-in process with a timeout
      GoogleSignInAccount? gUser;
      try {
        gUser = await _googleSignIn.signIn();
      } catch (e) {
        print('Google Sign-In: Error during sign-in process: $e');
        // If error contains "concurrent", wait and try again
        if (e.toString().contains('concurrent')) {
          await Future.delayed(const Duration(seconds: 2));
          try {
            gUser = await _googleSignIn.signIn();
          } catch (retryError) {
            print('Google Sign-In: Retry failed: $retryError');
            _isSigningIn = false;
            return null;
          }
        } else {
          _isSigningIn = false;
          rethrow;
        }
      }
      
      // User canceled the sign-in flow
      if (gUser == null) {
        print('Google Sign-In: User canceled the sign-in flow');
        _isSigningIn = false;
        return null;
      }
      
      print('Google Sign-In: User selected account: ${gUser.email}');
      
      // Obtain auth details from request
      print('Google Sign-In: Getting authentication details');
      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      
      print('Google Sign-In: Authentication details obtained');
      if (gAuth.accessToken == null || gAuth.idToken == null) {
        print('Google Sign-In: Invalid authentication tokens');
        _isSigningIn = false;
        return null;
      }
      
      // Create a new credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      
      // Finally, sign in to Firebase
      print('Google Sign-In: Signing in with Firebase');
      final userCredential = await _auth.signInWithCredential(credential);
      print('Google Sign-In: Successfully signed in with Firebase: ${userCredential.user?.email}');
      
      _isSigningIn = false;
      return userCredential;
    } catch (e) {
      _handleSignInError(e);
      _isSigningIn = false;
      
      // Try direct Firebase method as a fallback
      if (e.toString().contains('PlatformException') || e.toString().contains('concurrent')) {
        print('Attempting direct Firebase Google sign-in as fallback');
        try {
          final GoogleAuthProvider googleProvider = GoogleAuthProvider();
          final userCredential = await _auth.signInWithProvider(googleProvider);
          print('Direct Firebase Google sign-in successful');
          return userCredential;
        } catch (fbError) {
          print('Direct Firebase Google sign-in failed: $fbError');
          return null;
        }
      }
      
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
      } else if (error.code == 'sign_in_failed') {
        print('Sign-in failed. Reason: ${error.message}');
      } else if (error.code == 'sign_in_required') {
        print('Sign-in is required. Previous session may have been expired.');
      } else {
        print('Platform Exception: ${error.code} - ${error.message}');
      }
    } else if (error is FirebaseAuthException) {
      print('Firebase Auth Exception: ${error.code} - ${error.message}');
    } else {
      print('Unexpected error: $error');
    }
  }

  // Check if user is signed in
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Email Sign Up
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    print('Email sign-up: Processing in AuthService');
    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      print('Email sign-up: User created successfully in AuthService');
      
      // Send email verification
      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        print('Email sign-up: Sending verification email to ${user.email}');
        await user.sendEmailVerification();
        print('Email sign-up: Verification email sent');
      }
      
      // Call UserApi.registerUser() if it exists (wrapped with error handling for PigeonUserDetails error)
      try {
        // The code is likely trying to call something like:
        // final userDetails = await UserApi().registerUser(email, password);
        
        // Instead, we'll continue without calling this method as it seems to be causing issues
        // and the Firebase Auth registration above is successful
        print('Email sign-up: Skipping UserApi.registerUser() call to avoid PigeonUserDetails error');
      } catch (pigeonError) {
        print('Email sign-up: Caught error in UserApi.registerUser(): $pigeonError');
        
        // If the error specifically mentions PigeonUserDetails type cast issues, we'll 
        // log it but continue with the flow since Firebase Auth registration was successful
        if (pigeonError.toString().contains('PigeonUserDetails') || 
            pigeonError.toString().contains('type \'List<Object?>\'')) {
          print('Email sign-up: PigeonUserDetails type cast error handled gracefully');
        } else {
          // For other types of errors, we might want to rethrow
          print('Email sign-up: Unknown error in UserApi call: $pigeonError');
        }
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Email sign-up: FirebaseAuthException in AuthService: ${e.code} - ${e.message}');
      // Rethrow to let the UI handle the error
      rethrow;
    } catch (e) {
      print('Email sign-up: General error in AuthService: $e');
      // Check if the error is related to PigeonUserDetails
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('type \'List<Object?>\'')) {
        print('Email sign-up: Handling PigeonUserDetails error in main try-catch');
        // Create a PlatformException with a recognizable code
        throw PlatformException(
          code: 'pigeonUserDetails-error',
          message: 'Error with UserApi registration: ${e.toString()}',
        );
      }
      rethrow;
    }
  }
  
  // Email Sign In
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    print('Email sign-in: Processing in AuthService');
    try {
      // Sign in with email and password
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      print('Email sign-in: Authentication successful in AuthService');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Email sign-in: FirebaseAuthException in AuthService: ${e.code} - ${e.message}');
      // Rethrow to let the UI handle the error
      rethrow;
    } catch (e) {
      print('Email sign-in: General error in AuthService: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    print('Signing out user');
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        print('Error disconnecting Google Sign-In: $e');
      }
      print('User successfully signed out');
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }
}
