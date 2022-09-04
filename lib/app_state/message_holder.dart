import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app/chatbox.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageHolder extends ChangeNotifier {
  static const CLEAR_KEY = "ClearKey";
  MessageHolder(this.db) {
    init();
  }

  final FirebaseFirestore db;
  StreamSubscription<QuerySnapshot>? _chatMessagesSubscription;
  List<ChatMessage> _chatMessages = [];
  List<ChatMessage> get chatMessages => _chatMessages;
  DateTime _clearTill = DateTime.fromMillisecondsSinceEpoch(0);

  Future<DocumentReference> addChatToDB(String message) async {
    var uid2 = FirebaseAuth.instance.currentUser!.uid;
    return db.collection('chats').add(<String, dynamic>{
      'message': message,
      'timestamp': Timestamp.fromDate(DateTime.now()),
      'username': FirebaseAuth.instance.currentUser!.displayName,
      'userId': uid2,
      'usercolor': await db.collection('users').doc(uid2).get().then((documentSnapshot) => (documentSnapshot.data()?['usercolor'] as double).toInt())
    });
  }

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _clearTill =
        DateTime.fromMillisecondsSinceEpoch(prefs.getInt(CLEAR_KEY) ?? 0);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _chatMessagesSubscription = db
            .collection('chats')
            .orderBy('timestamp')
            .where('timestamp',
                isGreaterThanOrEqualTo: _clearTill)
            .snapshots()
            .listen((snapshot) {
          _chatMessages = [];
          for (final document in snapshot.docs) {
            _chatMessages.add(ChatMessage.fromJson(document.data()));
          }
          notifyListeners();
        });
      } else {
        _chatMessages = [];
        _chatMessagesSubscription?.cancel();
        notifyListeners();
      }
    });
  }

  void setClearTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _clearTill = DateTime.now();
    prefs.setInt(CLEAR_KEY, _clearTill.millisecondsSinceEpoch);
    _chatMessages = [];
    notifyListeners();
  }

  void resetClearTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(CLEAR_KEY, 0);
    _clearTill = DateTime.fromMillisecondsSinceEpoch(0);
    init();
    notifyListeners();
  }
}
