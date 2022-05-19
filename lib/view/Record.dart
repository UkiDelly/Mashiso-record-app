import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../preferences.dart';

class Record extends StatefulWidget {
  const Record({Key? key}) : super(key: key);

  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  List data = [];
  GeoPoint point = const GeoPoint(0, 0);
  late DateTime time = DateTime.now();
  var userId = LoginPreferences.getUserId();

  //test
  getRecord() async {
    final employee = await FirebaseFirestore.instance
        .collection('employee')
        .doc(userId)
        .collection('record')
        .orderBy('IN', descending: true)
        .get();

    for (int i = 0; i < employee.docs.length; i++) {
      data.add(employee.docs[i].data());
    }

    if (mounted) {
      setState(() {
        data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getRecord();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return recordCard(index);
      },
    ));
  }

  Widget recordCard(int index) {
    final timeIN = DateFormat.jm().format(data[index]['IN'].toDate());
    String timeOUT = '';
    if (data[index]['OUT'] != null) {
      timeOUT = DateFormat.jm().format(data[index]['OUT'].toDate());
    }
    String date = DateFormat.yMMMMd('en_US').format(data[index]['IN'].toDate());

    return Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffFDBF05), width: 3),
            borderRadius: BorderRadius.circular(20)),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              "IN: $timeIN",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffFDBF05)),
            ),
            Text(
              "OUT: $timeOUT",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget recordMap(GeoPoint location) {
    return GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(location.latitude, location.longitude)));
  }
}
