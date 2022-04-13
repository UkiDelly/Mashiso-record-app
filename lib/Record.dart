import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:work_record_app/preferences.dart';

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
        .orderBy('time', descending: true)
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
    var _time = DateFormat.jm().format(data[index]['time'].toDate());
    var _date = DateFormat.yMMMMd('en_US').format(data[index]['time'].toDate());
    return Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          15,
          10,
          5,
          10,
        ),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          const Spacer(),
          // Time and date
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                _time,
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              Text(
                _date,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Spacer(
            flex: 4,
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: data[index]['status'] == 'IN'
                    ? const Color(0xffFDBF05)
                    : Colors.transparent,
                border: Border.all(color: Colors.black, width: 5),
                borderRadius: const BorderRadius.all(Radius.circular(100))),
            child: Center(
                child: Text(
              "${data[index]['status']}",
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            )),
          )
        ]),
      ),
    );
  }

  Widget recordMap(GeoPoint location) {
    return GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(location.latitude, location.longitude)));
  }
}
