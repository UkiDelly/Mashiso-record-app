import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:location/location.dart';
import 'package:work_record_app/home.dart';
import 'package:work_record_app/preferences.dart';

import 'login.dart';

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
  String? userId = 'empty_user_id';
  var login;

  autoLogin() async {
    final employee = await FirebaseFirestore.instance
        .collection('employee')
        .doc(userId)
        .get();
    return employee.data();
  }

//*Service and permission
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  Location location = Location();
  //*check the permission
  checkPermission() async {
    //check the service in enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    //*check the permission is enabled
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }

    setState(() {
      _serviceEnabled;
      _permissionGranted;
    });
  }

  @override
  void initState() {
    super.initState();
    userId = LoginPreferences.getUserId();
    login = autoLogin();
    checkPermission();
  }

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
        darkTheme: ThemeData(
            fontFamily: 'Inter',
            primarySwatch: Colors.orange,
            brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        home:
            // const TimeInOut());
            FutureBuilder(
          future: login,
          builder: (context, user) {
            if (user.hasData) {
              Map<String, dynamic> data = user.data! as Map<String, dynamic>;
              return Home(
                name: data['name'],
                location: location,
              );
            } else if (user.connectionState == ConnectionState.waiting) {
              return Container(
                color: Colors.white,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return Login(
              location: location,
            );
          },
        ));
  }
}
