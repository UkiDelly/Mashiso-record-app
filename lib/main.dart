import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:work_record_app/preferences.dart';

import 'login.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await LoginPreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Work Record App',
        theme: ThemeData(
            fontFamily: 'Inter',
            primarySwatch: Colors.orange,
            brightness: Brightness.light),
        darkTheme: ThemeData(fontFamily: 'Inter', brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        home:
            // const TimeInOut());
            const Login());
  }
}
