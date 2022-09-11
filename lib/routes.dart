import 'package:final_app/app_state/login_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/register.dart';
import 'screens/login.dart';
import 'screens/chathome.dart';

class MyRouter {
  final LoginState loginState;
  MyRouter(this.loginState);

  static const ROOT = "Root";
  static const HOME = "ChatHome";
  static const REGISTER = "Register";
  static const LOGIN = "Login";

  late final router = GoRouter(
    redirectLimit: 10,
    refreshListenable: loginState,
    // Remove below b4 final
    debugLogDiagnostics: true,
    urlPathStrategy: UrlPathStrategy.path,

    routes: [
      GoRoute(
          name: ROOT,
          path: '/',
          redirect: (state) {
            if (loginState.loginState == ApplicationLoginState.loggedIn) {
              return state.namedLocation(HOME);
            }
            return state.namedLocation(LOGIN);
          }),
      GoRoute(
        name: HOME,
        path: '/home',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const MyHomePage(title: 'Chat Room'),
        ),
      ),
      GoRoute(
        name: LOGIN,
        path: '/login',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        name: REGISTER,
        path: '/register',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
    ],
    redirect: (state) {
      if (state.subloc == '/home' &&
          loginState.loginState == ApplicationLoginState.loggedOut) {
        return state.namedLocation(LOGIN);
      }
      return null;
    },
  );
}
