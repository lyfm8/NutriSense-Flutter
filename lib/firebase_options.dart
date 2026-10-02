// File này được tạo từ thông tin trong google-services.json của dự án Android cũ.
// Firebase project: nitrisense (project_number: 602435568303)
//
// Nếu cần cập nhật, chạy: dart pub global activate flutterfire_cli
// rồi: flutterfire configure

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Cấu hình cho Android (lấy từ google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAJeNKKrjtyO8CmUCpfCnuas9uJXlafawo',
    appId: '1:602435568303:android:2568381fe5f09973658a5a',
    messagingSenderId: '602435568303',
    projectId: 'nitrisense',
    storageBucket: 'nitrisense.firebasestorage.app',
  );

  // Web client ID (client_type: 3 trong google-services.json)
  // Dùng cho Google Sign-In
  static const String webClientId =
      '602435568303-prbkc9os272vrj9eh03288hr0d3ujo68.apps.googleusercontent.com';

  // Cấu hình web (nếu muốn chạy trên web, cần thêm apiKey web riêng)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAJeNKKrjtyO8CmUCpfCnuas9uJXlafawo',
    appId: '1:602435568303:android:2568381fe5f09973658a5a',
    messagingSenderId: '602435568303',
    projectId: 'nitrisense',
    storageBucket: 'nitrisense.firebasestorage.app',
    authDomain: 'nitrisense.firebaseapp.com',
  );
}
