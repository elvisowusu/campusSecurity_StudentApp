import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MessageState extends StatefulWidget {
  const MessageState({super.key});

  @override
  State<MessageState> createState() => _MessageStateState();
}

class _MessageStateState extends State<MessageState> {
  Map payload = {};

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments;
    //background and terminated state
    if (data is RemoteMessage) {
      payload = data.data;
    }

    // foreground state
    if (data is NotificationResponse) {
      payload = jsonDecode(data.payload!);
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Message'),
        ),
        body: Center(
          child: Text(payload.toString()),
        ));
  }
}
