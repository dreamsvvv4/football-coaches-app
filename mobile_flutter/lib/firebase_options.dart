import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (Platform.isIOS) {
      return ios;
    } else if (Platform.isAndroid) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyAndroidKeyForMVP12345',
    appId: '1:123456789:android:abc123def456',
    messagingSenderId: '123456789',
    projectId: 'football-coaches-app',
    storageBucket: 'football-coaches-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyIOSKeyForMVP67890',
    appId: '1:123456789:ios:xyz789uvw012',
    messagingSenderId: '123456789',
    projectId: 'football-coaches-app',
    storageBucket: 'football-coaches-app.appspot.com',
    iosBundleId: 'com.example.footballcoachesapp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDummyWebKeyForMVP34567',
    appId: '1:123456789:web:abc123def789xyz',
    messagingSenderId: '123456789',
    projectId: 'football-coaches-app',
    storageBucket: 'football-coaches-app.appspot.com',
    authDomain: 'football-coaches-app.firebaseapp.com',
  );
}
