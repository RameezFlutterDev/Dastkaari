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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAbDWTyCMFLDrLyh1aNYMqnZ6k3-V5cB9Y',
    appId: '1:1014351234378:web:126143756fc86f5765adb3',
    messagingSenderId: '1014351234378',
    projectId: 'chatappnetwork',
    authDomain: 'chatappnetwork.firebaseapp.com',
    databaseURL: 'https://chatappnetwork-default-rtdb.firebaseio.com',
    storageBucket: 'chatappnetwork.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmZsEGrdj9e6Z3uMmfkaOs7n46eloS7VE',
    appId: '1:1014351234378:android:1bab3bfafa7a8a3d65adb3',
    messagingSenderId: '1014351234378',
    projectId: 'chatappnetwork',
    databaseURL: 'https://chatappnetwork-default-rtdb.firebaseio.com',
    storageBucket: 'chatappnetwork.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBvHbv8Voz5pUQ50fCp33rvmXzDGBeTBYc',
    appId: '1:1014351234378:ios:a5742adf75d88c7a65adb3',
    messagingSenderId: '1014351234378',
    projectId: 'chatappnetwork',
    databaseURL: 'https://chatappnetwork-default-rtdb.firebaseio.com',
    storageBucket: 'chatappnetwork.appspot.com',
    iosBundleId: 'com.example.dastkaari',
  );

}