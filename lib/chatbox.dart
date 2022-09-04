import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app/app_state/theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatMessage {
  final String message;
  final DateTime timestamp;
  final String username;
  final int usercolor;

  const ChatMessage(this.message, this.timestamp, this.username, this.usercolor);

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
      json['message'] as String,
      (json['timestamp'] as Timestamp).toDate(),
      json['username'] as String,
      json['usercolor'] as int);
}

class ChatBox extends StatelessWidget {
  final bool isSameUser;
  final ChatMessage chat;
  const ChatBox({required this.isSameUser, required this.chat, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment:
            isSameUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 15.0),
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            constraints: const BoxConstraints(
              minWidth: 50.0,
              maxWidth: 300.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(150, 50, 50, 50),
                  blurRadius: 2.0,
                  spreadRadius: 2.0,
                  offset: Offset(2.0, 2.0),
                ),
              ],
              color: isSameUser
                  ? const Color.fromARGB(255, 15, 176, 0)
                  : Provider.of<DarkThemeProvider>(context, listen: true)
                          .darkTheme
                      ? const Color.fromARGB(255, 196, 163, 0)
                      : const Color.fromARGB(255, 255, 213, 0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(chat.username, style: TextStyle(fontWeight: FontWeight.bold, color: Color(chat.usercolor).withOpacity(1.0),),),
                    const Spacer(),
                    Text(
                      _showTime(chat.timestamp),
                      style: TextStyle(
                          fontSize: 10,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.8)),
                    )
                  ],
                ),
                Text(
                  chat.message,
                  style: const TextStyle(fontSize: 18),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ]);
  }

  String _showTime(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.day == now.day &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      return "${timestamp.hour}:${timestamp.minute}";
    }
    return "${timestamp.day}-${timestamp.month}-${timestamp.year} ${timestamp.hour}:${timestamp.minute}";
  }
}
