import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:chatapp/widgets/chat_messages.dart';
import 'package:chatapp/widgets/new_message.dart';
import 'package:chatapp/screens/profile_screen.dart';
import 'package:chatapp/screens/ai_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    //I want to ask permissions on this widget and get the address of this device
    final fcm = FirebaseMessaging.instance;

    //requests user permission to receive and process push notifications
    await fcm.requestPermission();

    fcm.subscribeToTopic('chat');
  }

  //this widget will only run once when first installed and will be used to do some initial setup work
  @override
  void initState() {
    super.initState();

    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatApp'),
        actions: [
          PopupMenuButton<PopupMenuEntry<dynamic>>(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.chat_rounded),
                    title: const Text(
                      'Talk to AI',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiScreen(),
                        ),
                      );
                    },
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text(
                      'Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.logout_rounded),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: const [
          Expanded(child: ChatMessages()),
          NewMessage(),
        ],
      ),
    );
  }
}
