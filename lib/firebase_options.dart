// File generated manually based on google-services.json
// For production, use: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return android; // Use Android config for Windows
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
    apiKey: 'AIzaSyAt7II24L5tcIsHH8AOEU-aeXCBwYsabz0',
    appId: '1:408477564800:web:0d7da0b7ab6cb72ea2cb65',
    messagingSenderId: '408477564800',
    projectId: 'medicinefirebase-398f6',
    authDomain: 'medicinefirebase-398f6.firebaseapp.com',
    storageBucket: 'medicinefirebase-398f6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAt7II24L5tcIsHH8AOEU-aeXCBwYsabz0',
    appId: '1:408477564800:android:0d7da0b7ab6cb72ea2cb65',
    messagingSenderId: '408477564800',
    projectId: 'medicinefirebase-398f6',
    storageBucket: 'medicinefirebase-398f6.firebasestorage.app',
  );
}

