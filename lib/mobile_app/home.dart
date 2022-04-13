import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:page_transition/page_transition.dart';
import 'package:work_record_app/mobile_app/add_employee.dart';
import 'package:work_record_app/mobile_app/employee_record.dart';

class MobileHome extends StatelessWidget {
  const MobileHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Logo
              SizedBox(
                  width: 250,
                  child: Image.asset(
                    'assets/mashiso.png',
                  )),

              //
              const SizedBox(
                height: 15,
              ),

              //Employee text and add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    "Employee",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),

                  //Add Employee
                  IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        PageTransition(
                            child: const AddEmployee(),
                            type: PageTransitionType.leftToRight)),
                    icon: const Icon(Icons.person_add),
                    color: const Color(0xffFDBF05),
                  )
                ],
              ),

              //Employee list
              const EmployeeList()
            ],
          ),
        ),
      ),
    );
  }
}

class EmployeeList extends StatefulWidget {
  const EmployeeList({Key? key}) : super(key: key);

  @override
  State<EmployeeList> createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  int numOfEmployees = 0;
  List nameList = [];
  List idList = [];
  getEmployeeList() async {
    final employee =
        await FirebaseFirestore.instance.collection('employee').get();
    numOfEmployees = employee.docs.length;

    for (var item in employee.docs) {
      nameList.add(item['name']);
      idList.add(item.id);
    }

    setState(() {
      numOfEmployees;
      nameList;
      idList;
    });
  }

  @override
  void initState() {
    super.initState();
    getEmployeeList();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
        child: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView.builder(
            //Remove the sliver padding
            padding: const EdgeInsets.all(0),
            scrollDirection: Axis.vertical,
            physics: const ScrollPhysics(),
            itemCount: numOfEmployees,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                elevation: 3,
                color: const Color(0xffFDBF05),
                child: ListTile(
                  title: Center(
                      child: Text(
                    "${nameList[index]}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  )),
                  onTap: () => Navigator.push(
                      context,
                      PageTransition(
                          child: EmployeeRecord(
                              employeeId: idList[index], name: nameList[index]),
                          type: PageTransitionType.rightToLeftWithFade)),
                  onLongPress: () => NAlertDialog(
                    content: const SizedBox(
                      height: 70,
                      child: Center(
                          child: Text(
                        "Are you sure to delete his employee?",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      )),
                    ),
                    actions: [
                      TextButton(
                          style: const ButtonStyle(
                              splashFactory: NoSplash.splashFactory),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
                          )),
                      TextButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('employee')
                                .doc(idList[index])
                                .delete();

                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    child: const MobileHome(),
                                    type: PageTransitionType.fade));
                          },
                          child: const Text(
                            "Ok",
                            style: TextStyle(color: Colors.red),
                          )),
                    ],
                  ).show(context),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
