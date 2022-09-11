import 'package:final_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_state/login_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'Register');
  final _validEmail = RegExp(
      r'^[a-zA-Z0-9]+(?:[_.-][a-zA-Z0-9])*@[a-zA-Z0-9-.]+?\.[a-zA-Z]{2,}$');

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

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
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Register New Account"),
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
                    constraints: const BoxConstraints(
                        minHeight: 420.0, maxHeight: 450.0),
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
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.account_box_rounded),
                            labelText: "Username",
                            focusedBorder: OutlineInputBorder(),
                          ),
                          autofillHints: const [AutofillHints.newUsername],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter a username';
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
                            labelText: "New Password",
                            focusedBorder: const OutlineInputBorder(),
                          ),
                          obscureText: _hidePassword,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return 'Password must be atleast 8 characters';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _hideConfirmPassword = !_hideConfirmPassword;
                                });
                              },
                              icon: (_hideConfirmPassword)
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                            ),
                            labelText: "Confirm Password",
                            focusedBorder: const OutlineInputBorder(),
                          ),
                          obscureText: _hideConfirmPassword,
                          enableSuggestions: false,
                          autocorrect: false,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
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
                                    _registerNewUser(
                                        _emailController.text,
                                        _usernameController.text,
                                        _passwordController.text);
                                    _toLoginPage();
                                  }
                                },
                                child: const Text("Register")),
                            ElevatedButton(
                                onPressed: () {
                                  _toLoginPage();
                                },
                                child: const Text("Go to Login")),
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

  void _registerNewUser(String email, String username, String password) {
    Provider.of<LoginState>(context, listen: false).email =
        _emailController.text;
    Provider.of<LoginState>(context, listen: false)
        .registerAccount(username, password, (e) {
      showErrorDialog(context, "Failed to create account", e);
    }, (dest) => context.goNamed(dest));
  }

  void _toLoginPage() {
    Provider.of<LoginState>(context, listen: false).email =
        _emailController.text;
    Provider.of<LoginState>(context, listen: false).startLoginFlow();
    context.goNamed(MyRouter.LOGIN);
  }

  void showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
