// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyB63KbjpaqHXAZJU-bmPlTFr7brmQatY_s',
    appId: '1:642511677324:web:8b106d971b47f9379dd8a9',
    messagingSenderId: '642511677324',
    projectId: 'health-care-94dbb',
    authDomain: 'health-care-94dbb.firebaseapp.com',
    storageBucket: 'health-care-94dbb.appspot.com',
    measurementId: 'G-1C5P25MHJ9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5xfDj3Az7ALm084WmA7Ak6RjxWDRK1S0',
    appId: '1:642511677324:android:72d46e8580048fdc9dd8a9',
    messagingSenderId: '642511677324',
    projectId: 'health-care-94dbb',
    storageBucket: 'health-care-94dbb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAHDl1vtSHO7JZQtDd1Ti5Miyp88qV8pXg',
    appId: '1:642511677324:ios:ec4efd4134fd9a169dd8a9',
    messagingSenderId: '642511677324',
    projectId: 'health-care-94dbb',
    storageBucket: 'health-care-94dbb.appspot.com',
    iosBundleId: 'com.example.healthcare',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAHDl1vtSHO7JZQtDd1Ti5Miyp88qV8pXg',
    appId: '1:642511677324:ios:ec4efd4134fd9a169dd8a9',
    messagingSenderId: '642511677324',
    projectId: 'health-care-94dbb',
    storageBucket: 'health-care-94dbb.appspot.com',
    iosBundleId: 'com.example.healthcare',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB63KbjpaqHXAZJU-bmPlTFr7brmQatY_s',
    appId: '1:642511677324:web:cb74ecc7a0864a4d9dd8a9',
    messagingSenderId: '642511677324',
    projectId: 'health-care-94dbb',
    authDomain: 'health-care-94dbb.firebaseapp.com',
    storageBucket: 'health-care-94dbb.appspot.com',
    measurementId: 'G-S3KRL026ZB',
  );
}