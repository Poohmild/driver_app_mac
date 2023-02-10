// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, must_be_immutable, unnecessary_null_comparison, use_build_context_synchronously

import 'package:drivers_app/allscreen/loginscreen.dart';
import 'package:drivers_app/main.dart';
import 'package:drivers_app/widget/progressDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  var input_name = TextEditingController();
  var input_email = TextEditingController();
  var input_password = TextEditingController();
  var input_phone = TextEditingController();
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
              "Register as a Driver",
              style: TextStyle(fontSize: 20),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: input_name,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(fontSize: 14),
                        hintText: "name",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10)),
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 5),
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
                    controller: input_phone,
                    decoration: InputDecoration(
                        labelText: "Phone",
                        labelStyle: TextStyle(fontSize: 14),
                        hintText: "phone",
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
                      registerNewUser(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.yellow),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Create Account",
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
                      Text("Already have an Account? "),
                      InkWell(
                          onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                              (route) => false),
                          child: Text("Login Here!")),
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
  registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => ProgressDialog(
              message: "Registering , Please wait....",
            ));
    final User? firebaseUser =
        (await _firebaseAuth.createUserWithEmailAndPassword(
                email: input_email.text, password: input_password.text))
            .user;
    if (firebaseUser != null) {
      Map userDataMap = {
        "name": input_name.text,
        "email": input_email.text,
        "phone": input_phone.text,
        "password": input_password.text
      };
      userRef.child(firebaseUser.uid).set(userDataMap);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false);
    } else {
      print("object");
    }
  }
}
