import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:travel_planner_app/features/auth/screens/notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  //PUSH NOTIFICATION
  Future<void> firebaseMessaging() async{
    print("firebasemessaging function started");
    //firebase messaging initialize
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    //fcm token
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    //foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      final title = message.notification?.title ?? "N/A";
      final body = message.notification?.body ?? "N/A";

      showDialog(context: context,
          builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(
              body,
            maxLines: 1,
            style: TextStyle(overflow: TextOverflow.ellipsis),
            ),
            actions: [
              TextButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context)=> NotificationDetailScreen(
                        title: title,
                        body: body,
                    ),
                ),
                );
              },
                  child: Text("Next")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    }, child: Text("cancel"),
              ),
            ],
          ),
      );
    });
    //app is not closed but is in background
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
  print("tapped");
final title = message.notification?.title ?? "N/A";
final body = message.notification?.body ?? "N/A";
Navigator.push(
context, MaterialPageRoute(
builder: (context)=> NotificationDetailScreen(
title: title,
body: body,
),
),
);
});
//app is in termination state
    FirebaseMessaging.instance.getInitialMessage().then((message){
      if(message !=null) {
        if (!mounted) return;
        final title = message.notification?.title ?? "N/A";
        final body = message.notification?.body ?? "N/A";
        Navigator.push(
          context, MaterialPageRoute(
          builder: (context) =>
              NotificationDetailScreen(
                title: title,
                body: body,
              ),
        ),
        );
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("init state called");
    //call the function
    firebaseMessaging();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text("Push Notification",
        style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
    );
  }
}
