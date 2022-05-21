import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import '../preferences.dart';

class TimeInOut {
  final String userId;

  TimeInOut(this.userId);

  //*Send Firebase
  timeInUpload(String name, DateTime time, Position location) async {
    var userId = LoginPreferences.getUserId();
    await FirebaseFirestore.instance
        .collection('employee')
        .doc(userId)
        .collection('record')
        .add({
      'name': name,
      'IN': Timestamp.fromDate(time),
      'locationIN': GeoPoint(location.latitude, location.longitude)
    });

    Fluttertoast.showToast(
        msg: "Successfully Time in!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 20.0);
  }

  timeOutUpLoad(DateTime time, var location) async {
    var userId = LoginPreferences.getUserId();
    final employee = await FirebaseFirestore.instance
        .collection('employee')
        .doc(userId)
        .collection('record')
        .orderBy('IN', descending: true)
        .get();

    String id = employee.docs.first.id;
    await FirebaseFirestore.instance
        .collection('employee')
        .doc(userId)
        .collection('record')
        .doc(id)
        .update({
      "OUT": Timestamp.fromDate(time),
      "locationOUT": GeoPoint(location.latitude, location.longitude)
    });

    Fluttertoast.showToast(
        msg: "Successfully Time Out!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 20.0);
  }
}
