import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:work_record_app/time_in_out.dart';

Color mainColor = const Color(0xffFDBF05);

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: _Login()),
    );
  }
}

class _Login extends StatefulWidget {
  const _Login({Key? key}) : super(key: key);

  @override
  State<_Login> createState() => __LoginState();
}

class __LoginState extends State<_Login> {
  TextEditingController usernameController = TextEditingController(),
      passwordController = TextEditingController();
  //GlobalKey for the valdation
  final formGlobalKey = GlobalKey<FormState>();
  dynamic exist = 'null';
  bool showPassword = false;
  String username = "", password = "";
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
      username = employee.docs.first.data()['username'];
      password = employee.docs.first.data()['password'];
      exist = employee.docs.first.exists;
    }
    setState(() {
      exist;
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
    print(username + password);
    return Form(
      key: formGlobalKey,
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
              // validator
              //TODO: Add validator
              // validator: (value) {
              //   if (value == null) {
              //     return "Didn't enter anything";
              //   }
              //   return "";
              // },
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
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          child: const TimeInOut(),
                          type: PageTransitionType.fade));
                } else {
                  setState(() {
                    usernameController.text = "";
                    passwordController.text = "";
                  });
                }
              },
              child: const Text(
                "Login",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(mainColor)),
            ),
          ),
        ],
      ),
    );
  }
}
