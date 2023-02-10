// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, must_be_immutable, use_build_context_synchronously

import 'package:drivers_app/allscreen/mainscreen.dart';
import 'package:drivers_app/allscreen/registerscreen.dart';
import 'package:drivers_app/widget/progressDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  var input_email = TextEditingController(text: "");
  var input_password = TextEditingController(text: "");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 65),
            Align(
                alignment: Alignment.center,
                child: Image.asset("images/logo.png")),
            Text(
              "login as a Driver",
              style: TextStyle(fontSize: 20),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: input_email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14),
                        hintText: "email",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10)),
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: input_password,
                    // obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14),
                        hintText: "password",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10)),
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 25),
                  InkWell(
                    onTap: () {
                      loginAndAuthenticateUser(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.yellow),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Do not have an Account? "),
                      InkWell(
                          onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()),
                              (route) => false),
                          child: Text("Register Here!")),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginAndAuthenticateUser(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => ProgressDialog(
              message: "Authenticating, Please wait....",
            ));
    final User? firebaseUser = (await _firebaseAuth.signInWithEmailAndPassword(
            email: input_email.text, password: input_password.text))
        .user;

    if (firebaseUser != null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainSrceen()),
          (route) => false);
    } else {
      _firebaseAuth.signOut();
      print("signout");
      print("object");
    }
  }
}
