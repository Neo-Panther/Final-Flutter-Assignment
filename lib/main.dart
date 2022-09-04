import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app/app_state/login_state.dart';
import 'package:final_app/app_state/message_holder.dart';
import 'package:final_app/themestyles.dart';
import 'package:flutter/material.dart';
import 'app_state/theme_preference.dart';
import 'routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final db = FirebaseFirestore.instance;
  runApp(MyApp(db));
}

class MyApp extends StatefulWidget {
  MyApp(this.db, {Key? key})
      : loginState = LoginState(db),
        messageState = MessageHolder(db),
        super(key: key);

  final FirebaseFirestore db;
  final LoginState loginState;
  final MessageHolder messageState;

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<MessageHolder>(
            lazy: false,
            create: (_) => widget.messageState,
          ),
          ChangeNotifierProvider<LoginState>(
            lazy: false,
            create: (BuildContext createContext) => widget.loginState,
          ),
          Provider<MyRouter>(
            lazy: false,
            create: (BuildContext createContext) => MyRouter(widget.loginState),
          ),
          ChangeNotifierProvider<DarkThemeProvider>(
            create: (_) => themeChangeProvider,
          ),
        ],
        child: Builder(builder: (BuildContext context) {
          final router = Provider.of<MyRouter>(context, listen: false).router;
          return MaterialApp.router(
            routeInformationProvider: router.routeInformationProvider,
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
            title: 'Chat Room',
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(Provider.of<DarkThemeProvider>(context, listen: true).darkTheme, context),
          );
        }));
  }
}
