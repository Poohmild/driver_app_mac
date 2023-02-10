// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'DataHandler/appData.dart';
import 'allscreen/loginscreen.dart';
import 'allscreen/mainscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Taxi Rider App',
        theme: ThemeData(
            fontFamily: "Brand Bold",
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: FirebaseAuth.instance.currentUser == null
            ? LoginScreen()
            : MainSrceen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
