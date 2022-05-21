import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:work_record_app/preferences.dart';
import 'Firebase/firebase_options.dart';
import 'models/user.dart';
import 'view/home.dart';
import 'view/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LoginPreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EmployeeApp();
  }
}

class EmployeeApp extends StatefulWidget {
  const EmployeeApp({Key? key}) : super(key: key);

  @override
  State<EmployeeApp> createState() => _EmployeeAppState();
}

class _EmployeeAppState extends State<EmployeeApp> {
  String? userId = 'empty_user_id';
  var login;
  late bool hasInternet;
  User user = User();

//*Service and permission
  late bool _serviceEnabled;
  late LocationPermission _permissionGranted;

  //*check the permission
  checkPermission() async {
    //check the service in enabled
    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      await Geolocator.requestPermission();
    }

    //*check the permission is enabled
    _permissionGranted = await Geolocator.checkPermission();
    if (_permissionGranted == LocationPermission.denied) {
      _permissionGranted = await Geolocator.requestPermission();
    }

    setState(() {
      _serviceEnabled;
      _permissionGranted;
    });
  }

  checkInternetConnection() async {
    bool hasInternet = await InternetConnectionChecker().hasConnection;
    if (!hasInternet) {
      const AlertDialog(
        title: Text("Warning"),
        content: Center(
          child: Text("Please connect to the internet."),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    userId = LoginPreferences.getUserId();
    login = user.auto_login(userId);
    checkPermission();
  }

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
        home: FutureBuilder(
          future: login,
          builder: (context, user) {
            if (user.hasData) {
              Map<String, dynamic> data = user.data! as Map<String, dynamic>;
              return Home(
                name: data['name'],
              );
            } else if (user.connectionState == ConnectionState.waiting) {
              return Container(
                color: Colors.white,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return const Login();
          },
        ));
  }
}
