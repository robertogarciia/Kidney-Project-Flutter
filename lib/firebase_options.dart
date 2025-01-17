// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyCp1agkWx5APKqwWvg-jrOu8rNf3AeHyww',
    appId: '1:900749590186:web:dbb0d26a9107d129901ad3',
    messagingSenderId: '900749590186',
    projectId: 'fir-kidenyproject',
    authDomain: 'fir-kidenyproject.firebaseapp.com',
    storageBucket: 'fir-kidenyproject.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvWzr8WSV-9xJOP9Yl1SA7Hy-LqT1wE5I',
    appId: '1:900749590186:android:5f308cf54addf887901ad3',
    messagingSenderId: '900749590186',
    projectId: 'fir-kidenyproject',
    storageBucket: 'fir-kidenyproject.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD15KrUu8Tsc8ZmmXkpRx3vStqJCl7CeB8',
    appId: '1:900749590186:ios:f773fc3d7bdd0e68901ad3',
    messagingSenderId: '900749590186',
    projectId: 'fir-kidenyproject',
    storageBucket: 'fir-kidenyproject.appspot.com',
    iosClientId: '900749590186-q66htmk8ub3dmap3hivp559k7d4jgqj1.apps.googleusercontent.com',
    iosBundleId: 'com.example.kidneyproject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD15KrUu8Tsc8ZmmXkpRx3vStqJCl7CeB8',
    appId: '1:900749590186:ios:d97e9562fb07dec3901ad3',
    messagingSenderId: '900749590186',
    projectId: 'fir-kidenyproject',
    storageBucket: 'fir-kidenyproject.appspot.com',
    iosClientId: '900749590186-oprtrjm4kboem16bhe8o7cbf16g5futj.apps.googleusercontent.com',
    iosBundleId: 'com.example.kidneyproject.RunnerTests',
  );
}
