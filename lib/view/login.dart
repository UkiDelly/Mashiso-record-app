import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';

import '../preferences.dart';
import 'home.dart';

Color mainColor = const Color(0xffFDBF05);

// ignore: must_be_immutable
class Login extends StatelessWidget {
  Location location;
  Login({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: _Login(
        location: location,
      )),
    );
  }
}

// ignore: must_be_immutable
class _Login extends StatefulWidget {
  Location location;
  _Login({Key? key, required this.location}) : super(key: key);

  @override
  State<_Login> createState() => __LoginState();
}

class __LoginState extends State<_Login> {
  TextEditingController usernameController = TextEditingController(),
      passwordController = TextEditingController();
  //GlobalKey for the valdation
  dynamic exist = 'null';
  bool showPassword = false;
  String username = "", password = "", name = "";
  String userId = "";

  bool hasInternet = false;
  //login function
  login() async {
    final employee = await FirebaseFirestore.instance
        .collection('employee')
        .where('username', isEqualTo: usernameController.text)
        .where('password', isEqualTo: passwordController.text)
        .get();

    // check if there is data
    if (employee.size == 0) {
      exist = false;
    } else {
      userId = employee.docs.first.id;
      name = employee.docs.first.data()['name'];
      username = employee.docs.first.data()['username'];
      password = employee.docs.first.data()['password'];
      exist = employee.docs.first.exists;
    }
    setState(() {
      exist;
      name;
      username;
      password;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Logo
          Image.asset(
            'assets/mashiso.png',
            height: 200,
          ),

          const SizedBox(
            height: 36,
          ),
          //Username
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextFormField(
              controller: usernameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                  focusColor: Color(0xffFDBF05),
                  prefixIcon: Icon(Icons.person),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xffFDBF05), width: 3),
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  hintText: "Enter username",
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xffFDBF05), width: 3),
                      borderRadius: BorderRadius.all(Radius.circular(25)))),
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          //Password
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextFormField(
                obscureText: !showPassword,
                textInputAction: TextInputAction.done,
                controller: passwordController,
                decoration: InputDecoration(
                  // Lock icon
                  prefixIcon: const Icon(Icons.lock),

                  //show password
                  suffixIcon: IconButton(
                      splashColor: Colors.white.withOpacity(0),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                      icon: showPassword
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.visibility)),

                  focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xffFDBF05), width: 3),
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  hintText: "Enter password",
                  enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xffFDBF05), width: 3),
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                ),
              )),
          const SizedBox(
            height: 12,
          ),

          //Login Button
          SizedBox(
            width: 170,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await login();

                if (exist) {
                  await LoginPreferences.saveUserId(userId);
                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          child: Home(
                            name: name,
                            location: widget.location,
                          ),
                          type: PageTransitionType.fade));
                } else {
                  setState(() {
                    usernameController.text = "";
                    passwordController.text = "";
                  });
                }
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(mainColor)),
              child: const Text(
                "Login",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}