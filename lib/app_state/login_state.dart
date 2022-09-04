import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum ApplicationLoginState {
  loggedOut,
  register,
  loggedIn,
}

class LoginState extends ChangeNotifier {
  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;
  final FirebaseFirestore db;

  String? email;

  LoginState(this.db) {
    init();
  }

  void init() {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
        }
        else {
          _loginState = ApplicationLoginState.loggedOut;
        }
    });
  }

  void startLoginFlow() {
    _loginState = ApplicationLoginState.loggedOut;
  }

  void startRegisterFlow() {
    _loginState = ApplicationLoginState.register;
  }

  Future<void> verifyEmail(
    void Function(Exception e) errorCallback,
  ) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email!);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.loggedOut;
      } else {
        errorCallback(Exception("Register a New Account with this email"));
        _loginState = ApplicationLoginState.register;
      }
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  Future<void> registerAccount(
      String displayName,
      String password,
      void Function(FirebaseAuthException e) errorCallback,
      void Function(String destination) goNamed) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email!, password: password);
      await credential.user!.updateDisplayName(displayName);
      await db.collection('users').doc(credential.user!.uid).set(<String, dynamic>{
        'userId': credential.user!.uid,
        'username': displayName,
        'usercolor': (Random().nextDouble()*9868650) + 13158300,
      });
      _loginState = ApplicationLoginState.loggedOut;
      goNamed(MyRouter.LOGIN);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    _loginState = ApplicationLoginState.loggedOut;
  }

  Future<void> signInWithEmailAndPassword(
      String password,
      void Function(FirebaseAuthException e) errorCallback,
      void Function(String destination) goNamed) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email!,
        password: password,
      );
      _loginState = ApplicationLoginState.loggedIn;
      goNamed(MyRouter.HOME);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }
}
