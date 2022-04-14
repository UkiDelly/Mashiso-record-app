import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:work_record_app/mobile_app/home.dart';

class AddEmployee extends StatelessWidget {
  const AddEmployee({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: AddNewEmployeeWidget()),
    );
  }
}

class AddNewEmployeeWidget extends StatefulWidget {
  const AddNewEmployeeWidget({Key? key}) : super(key: key);

  @override
  State<AddNewEmployeeWidget> createState() => _AddNewEmployeeWidgetState();
}

class _AddNewEmployeeWidgetState extends State<AddNewEmployeeWidget> {
  TextEditingController nameController = TextEditingController(),
      usernameController = TextEditingController(),
      passwordController = TextEditingController();

  addEmployee() async {
    await FirebaseFirestore.instance.collection('employee').add({
      'username': usernameController.text,
      'name': nameController.text,
      'password': passwordController.text
    });

    Fluttertoast.showToast(
        msg: "Successfully Add a new employee!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 20.0);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Logo
            Center(
              child: Image.asset(
                'assets/mashiso.png',
                height: 250,
              ),
            ),

            const SizedBox(
              height: 30,
            ),
            // name
            SizedBox(
              width: 300,
              child: TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    focusColor: Color(0xffFDBF05),
                    prefixIcon: Icon(Icons.alternate_email),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffFDBF05), width: 3),
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    hintText: "Enter name",
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffFDBF05), width: 3),
                        borderRadius: BorderRadius.all(Radius.circular(25)))),
              ),
            ),

            //
            const SizedBox(
              height: 10,
            ),
            //username
            SizedBox(
              width: 300,
              child: TextField(
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

            //
            const SizedBox(
              height: 10,
            ),

            //password
            SizedBox(
              width: 300,
              child: TextField(
                controller: passwordController,
                textInputAction: TextInputAction.next,
                obscureText: true,
                decoration: const InputDecoration(
                    focusColor: Color(0xffFDBF05),
                    prefixIcon: Icon(Icons.lock),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffFDBF05), width: 3),
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    hintText: "Enter password",
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffFDBF05), width: 3),
                        borderRadius: BorderRadius.all(Radius.circular(25)))),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            //Add Button
            SizedBox(
              width: 170,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    usernameController;
                    nameController;
                    passwordController;
                  });

                  addEmployee();

                  Future.delayed(
                      const Duration(seconds: 1),
                      (() => Navigator.pushReplacement(
                          context,
                          PageTransition(
                              child: const MobileHome(),
                              type: PageTransitionType.leftToRight))));
                },
                child: const Text(
                  "Add",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xffFDBF05))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
