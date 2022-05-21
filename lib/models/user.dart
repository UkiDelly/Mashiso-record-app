import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? username, password;
  String userId = "";

  User({this.username, this.password});

  // login
  Future<bool> login() async {
    final employee = await FirebaseFirestore.instance
        .collection('employee')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .get();

    // check if there is data
    if (employee.size == 0) {
      return false;
    }
    userId = employee.docs.first.id;
    return employee.docs.first.exists;
  }

  // auto login
  auto_login(String? employeeId) async {
    final employee = await FirebaseFirestore.instance
        .collection('employee')
        .doc(employeeId)
        .get();

        return employee.data();
  }

  // get name
  get getUsername => username;
}
