// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
// / import 'firebase_options.dart';
// / // ...
// / await Firebase.initializeApp(
// /   options: DefaultFirebaseOptions.currentPlatform,
// / );
// / ```
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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBXu7o_wgrVx7cQlvAfYbOwsUxW9FWckKQ',
    appId: '1:753646007909:web:d1dae9583cc8441456b88c',
    messagingSenderId: '753646007909',
    projectId: 'irvinehacks2025-6d767',
    authDomain: 'irvinehacks2025-6d767.firebaseapp.com',
    storageBucket: 'irvinehacks2025-6d767.firebasestorage.app',
    measurementId: 'G-SRN9ZT3LDN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBhNdZL22AhGCl852_hzJ6MVJMxoxVgHQY',
    appId: '1:753646007909:android:02905b8c6853c29656b88c',
    messagingSenderId: '753646007909',
    projectId: 'irvinehacks2025-6d767',
    storageBucket: 'irvinehacks2025-6d767.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDOVFSSZ2Mokl888NHq2EVNTIQSyvZ-_EM',
    appId: '1:753646007909:ios:1fe61d5c8759af1a56b88c',
    messagingSenderId: '753646007909',
    projectId: 'irvinehacks2025-6d767',
    storageBucket: 'irvinehacks2025-6d767.firebasestorage.app',
    iosBundleId: 'com.example.flutterApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDOVFSSZ2Mokl888NHq2EVNTIQSyvZ-_EM',
    appId: '1:753646007909:ios:1fe61d5c8759af1a56b88c',
    messagingSenderId: '753646007909',
    projectId: 'irvinehacks2025-6d767',
    storageBucket: 'irvinehacks2025-6d767.firebasestorage.app',
    iosBundleId: 'com.example.flutterApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBXu7o_wgrVx7cQlvAfYbOwsUxW9FWckKQ',
    appId: '1:753646007909:web:6b9be76abeaa037c56b88c',
    messagingSenderId: '753646007909',
    projectId: 'irvinehacks2025-6d767',
    authDomain: 'irvinehacks2025-6d767.firebaseapp.com',
    storageBucket: 'irvinehacks2025-6d767.firebasestorage.app',
    measurementId: 'G-12E40HQSQL',
  );
}