import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'firebase_options.dart';

Future<void>_backgroundMessaging(RemoteMessage message)async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
Future<void> getFcmToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM TOKEN: $token');
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
FirebaseMessaging.onBackgroundMessage(_backgroundMessaging);
await getFcmToken();
  runApp(const MyApp());
}