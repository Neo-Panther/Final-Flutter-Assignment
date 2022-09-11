import 'package:final_app/app_state/login_state.dart';
import 'package:final_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'Login');
  final _validEmail = RegExp(
      r'^[a-zA-Z0-9]+(?:[_.-][a-zA-Z0-9])*@[a-zA-Z0-9-.]+?\.[a-zA-Z]{2,}$');

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  void initState() {
    _emailController.text =
        Provider.of<LoginState>(context, listen: false).email ?? "";
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Login"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.mail_outline_rounded),
                            labelText: "Email",
                            focusedBorder: OutlineInputBorder(),
                          ),
                          autofillHints: const [
                            AutofillHints.email,
                          ],
                          validator: (value) {
                            if (value == null ||
                                (!_validEmail.hasMatch(value))) {
                              return 'Enter a valid Email Address';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              },
                              icon: (_hidePassword)
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                            ),
                            labelText: "Password",
                            focusedBorder: const OutlineInputBorder(),
                          ),
                          obscureText: _hidePassword,
                          autofillHints: const [AutofillHints.password],
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return 'Password is atleast 8 characters';
                            }
                            return null;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _login();
                                  }
                                },
                                child: const Text("Login")),
                            ElevatedButton(
                                onPressed: () {
                                  _toRegisterPage();
                                },
                                child: const Text("Register New User")),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    Provider.of<LoginState>(context, listen: false).email =
        _emailController.text;
    Provider.of<LoginState>(context, listen: false).verifyEmail((e) {
      showErrorDialog(context, "Email not found, please register", e);
      _toRegisterPage();
      return;
    });
    Provider.of<LoginState>(context, listen: false)
        .signInWithEmailAndPassword(_passwordController.text, (e) {
      showErrorDialog(context, "Failed to sign in", e);
    }, (dest) => context.goNamed(dest));
  }

  void _toRegisterPage() {
    Provider.of<LoginState>(context, listen: false).email =
        _emailController.text;
    Provider.of<LoginState>(context, listen: false).startRegisterFlow();
    context.goNamed(MyRouter.REGISTER);
  }

  void showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded),
          title: Text(
            title,
            style: const TextStyle(fontSize: 24),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '${(e as dynamic).message}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }
}
