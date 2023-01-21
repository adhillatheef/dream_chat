import 'package:dream_chat/widgets/messages.dart';
import 'package:dream_chat/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _initNotifications() async {
    final notifications = FirebaseMessaging.instance;
    final settings = await notifications.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }

    FirebaseMessaging.onMessage.listen((msg) {
      debugPrint("onMessage: $msg");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      debugPrint("onMessageOpenedApp: $msg");
    });
  }

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Chat'),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Column(
        children: const [
          Expanded(child: Messages()),
          NewMessage()
        ],
      ),
    );
  }
}
