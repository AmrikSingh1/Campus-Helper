import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Configuration for Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAk09EDuyvRKFyAXd7xk5HRr0A_z5ekzSs',
    appId: '1:979079828996:android:f2d41eddbaa839e57bc751',
    messagingSenderId: '979079828996',
    projectId: 'campus-helper-335c4',
    storageBucket: 'campus-helper-335c4.firebasestorage.app',
  );

  // Configuration for iOS - using default values for now
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAk09EDuyvRKFyAXd7xk5HRr0A_z5ekzSs',
    appId: '1:979079828996:ios:defaultios1234567890',
    messagingSenderId: '979079828996',
    projectId: 'campus-helper-335c4',
    storageBucket: 'campus-helper-335c4.firebasestorage.app',
  );

  // Configuration for Web
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAk09EDuyvRKFyAXd7xk5HRr0A_z5ekzSs',
    appId: '1:979079828996:web:defaultweb1234567890',
    messagingSenderId: '979079828996',
    projectId: 'campus-helper-335c4',
    storageBucket: 'campus-helper-335c4.firebasestorage.app',
    authDomain: 'campus-helper-335c4.firebaseapp.com',
  );

  // Configuration for macOS - using default values for now
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAk09EDuyvRKFyAXd7xk5HRr0A_z5ekzSs',
    appId: '1:979079828996:macos:defaultmacos1234567890',
    messagingSenderId: '979079828996',
    projectId: 'campus-helper-335c4',
    storageBucket: 'campus-helper-335c4.firebasestorage.app',
  );
} 