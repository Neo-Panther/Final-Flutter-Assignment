import 'package:final_app/app_state/theme_preference.dart';
import 'package:final_app/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chatbox.dart';
import 'package:final_app/app_state/login_state.dart';
import 'package:final_app/app_state/message_holder.dart';
import 'package:go_router/go_router.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _sendTextController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _sendTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              title: Text(widget.title),
              actions: [
                IconButton(
                    onPressed:
                        Provider.of<DarkThemeProvider>(context, listen: false)
                            .switchTheme,
                    icon: Icon(
                        (Provider.of<DarkThemeProvider>(context, listen: true)
                                .darkTheme)
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded)),
                PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: 0,
                        child: Text("Signout"),
                      ),
                      const PopupMenuItem(
                        value: 1,
                        child: Text("Clear All Messages"),
                      ),
                      const PopupMenuItem(
                        value: 2,
                        child: Text("Restore All messages"),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    switch (value) {
                      case 0:
                        Provider.of<LoginState>(context, listen: false)
                            .signOut();
                        context.goNamed(MyRouter.LOGIN);
                        break;
                      case 1:
                        Provider.of<MessageHolder>(context, listen: false)
                            .setClearTime();
                        break;
                      case 2:
                        Provider.of<MessageHolder>(context, listen: false)
                            .resetClearTime();
                        break;
                    }
                  },
                )
              ],
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Stack(children: [
                    Consumer<MessageHolder>(
                        builder: ((context, messageHolder, child) =>
                            ListView.builder(
                                controller: _scrollController,
                                itemCount: messageHolder.chatMessages.length,
                                itemBuilder: (context, index) {
                                  return ChatBox(
                                      isSameUser: messageHolder
                                              .chatMessages[index].username ==
                                          FirebaseAuth.instance.currentUser!
                                              .displayName,
                                      chat: messageHolder.chatMessages[index]);
                                }))),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: _scrollToBottom,
                        child: const Icon(Icons.arrow_downward_rounded),
                      ),
                    )
                  ])),
                  const SendForm(),
                ])));
  }

  void _scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2), curve: Curves.fastOutSlowIn);
  }
}

class SendForm extends StatefulWidget {
  const SendForm({super.key});

  @override
  SendFormState createState() => SendFormState();
}

class SendFormState extends State<SendForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_SendMessage');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: TextFormField(
                  onFieldSubmitted: _send,
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    fillColor:
                        Provider.of<DarkThemeProvider>(context, listen: true)
                                .darkTheme
                            ? Colors.black
                            : Colors.white,
                    filled: true,
                    labelText: "Write a message",
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a message to send';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: FittedBox(
                child: Ink(
                  decoration: ShapeDecoration(
                    shape: const CircleBorder(),
                    color: Provider.of<DarkThemeProvider>(context, listen: true)
                            .darkTheme
                        ? const Color.fromARGB(255, 0, 155, 0)
                        : const Color.fromARGB(255, 0, 255, 0),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await Provider.of<MessageHolder>(context, listen: false)
                            .addChatToDB(_controller.text);
                        _controller.clear();
                      }
                    },
                    tooltip: 'Send',
                    color: Provider.of<DarkThemeProvider>(context, listen: true)
                            .darkTheme
                        ? Colors.white70
                        : Colors.black87,
                    icon: const Icon(Icons.send),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send(String message) async {
    if (_formKey.currentState!.validate()) {
      await Provider.of<MessageHolder>(context, listen: false)
          .addChatToDB(message);
      _controller.clear();
    }
  }
}
