import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_repository.dart';

class LoginPage extends StatelessWidget {
  final _loginFont = const TextStyle(fontSize: 20, height: 1.5);
  final unsuccessfulLoginSnackBar =
      SnackBar(content: Text('There was an error logging into the app'));
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
        builder: (context, auth, _) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(title: Text('Login')),
            body: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    'Welcome to Startup Names Generator, please log in below',
                    textAlign: TextAlign.left,
                    style: _loginFont,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'Enter valid mail id as abc@gmail.com'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    controller: passController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter 6 digits password',
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(15),
                    child: auth.status == Status.Authenticating
                        ? LinearProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red, // background
                              onPrimary: Colors.white, // foreground
                            ),
                            onPressed: () async {
                              bool signedIn = await auth.signIn(
                                  emailController.text, passController.text);
                              if (!signedIn) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(unsuccessfulLoginSnackBar);
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(
                              'Login',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            ),
                          )),
                Padding(
                    padding: EdgeInsets.all(15),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black12, // background
                        onPrimary: Colors.white, // foreground
                      ),
                      onPressed: () {
                        _pushSignUp(
                            context, emailController.text, passController.text);
                      },
                      child: Text(
                        'New user? Click to sign up',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ))
              ],
            )));
  }
}

void _pushSignUp(BuildContext context, String email, String password) {
  TextEditingController passConfirmController = new TextEditingController();

  showModalBottomSheet(
      context: context,
      builder: (context) {
        bool confirmedText = true;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateModal) {
          return Wrap(
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(children: [
                    Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                    Text("Please confirm your password below:"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0)),
                        Container(
                          width: 350,
                          child: TextField(
                            controller: passConfirmController,
                            decoration: InputDecoration(
                                labelText: 'Password',
                                errorText: confirmedText == false
                                    ? 'Passwords must match'
                                    : null,
                                labelStyle: TextStyle(color: Colors.red)),
                          ),
                        ),
                        Padding(padding: EdgeInsets.fromLTRB(0, 0, 20, 0)),
                      ],
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                    Consumer<AuthRepository>(
                      builder: (context, auth, _) => ElevatedButton(
                          onPressed: () {
                            passwordConfirm(context, auth, email, password,
                                    passConfirmController.text)
                                .then((value) {
                              if (!value) {
                                setStateModal(() {
                                  confirmedText = false;
                                });
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.teal[700]),
                          child: Text("Confirm")),
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0))
                  ])),
            ],
          );
        });
      });
}

Future<bool> passwordConfirm(BuildContext context, AuthRepository auth, String email, String first, String second) async {
  if (first != second) {
    return false;
  }
  if (await auth.signUp(email, first)!=null){
    Navigator.pop(context);
    Navigator.pop(context);
  }
  return true;
}
