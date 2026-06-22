import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'package:travel_planner_app/features/auth/screens/notification_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@pragma('vm:entry-point')
Future<void>_backgroundMessaging(RemoteMessage message)async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("background message recieved");
}
Future<void> getFcmToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM TOKEN: $token');
}
final GlobalKey<NavigatorState>
navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

FirebaseMessaging.onBackgroundMessage(_backgroundMessaging);
await getFcmToken();
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
    print("tapped");
    final title = message.notification?.title ?? "N/A";
    final body = message.notification?.body ?? "N/A";
    navigatorKey.currentState?.push(
      MaterialPageRoute(
      builder: (_)=> NotificationDetailScreen(
        title: title,
        body: body,
      ),
    ),
    );});

  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    final title = initialMessage.notification?.title ?? "N/A";
    final body = initialMessage.notification?.body ?? "N/A";

    Future.delayed(const Duration(seconds: 1), () {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => NotificationDetailScreen(
            title: title,
            body: body,
          ),
        ),
      );
    });
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("FOREGROUND MESSAGE RECEIVED");

    final title = message.notification?.title ?? "N/A";
    final body = message.notification?.body ?? "N/A";

    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (_) => NotificationDetailScreen(
                    title: title,
                    body: body,
                  ),
                ),
              );
            },
            child: const Text("Open"),
          ),
        ],
      ),
    );
  });

  runApp(
      const ProviderScope(
        child: MyApp(),
      ));
}