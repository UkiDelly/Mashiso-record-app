import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login.dart';
import 'time_in_out.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
