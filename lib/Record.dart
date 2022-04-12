import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Record extends StatefulWidget {
  const Record({Key? key}) : super(key: key);

  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  List data = [];
  GeoPoint point = const GeoPoint(0, 0);
  late DateTime time = DateTime.now();
  //test
  test() async {
    final employee = await FirebaseFirestore.instance
        .collection('employee')
        .doc('vuUn9uuoTxFLyJ3zd4Fu')
        .collection('record')
        .get();

    for (int i = 0; i < employee.docs.length; i++) {
      data.add(employee.docs[i].data());
    }

    if (mounted) {
      setState(() {
        data;
        point = data[0]['location'];
        time = DateTime.fromMicrosecondsSinceEpoch(data[0]['time'] * 1000);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    test();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("${data[0]}"),
          const SizedBox(
            height: 30,
          ),
          Text("${point.latitude}, ${point.longitude}"),
          const SizedBox(
            height: 30,
          ),
          Text(
              "${time.year}-${time.month}-${time.day} 오후 ${time.hour - 12}:${time.minute}"),
          const SizedBox(
            height: 30,
          ),
          recordCard()
        ],
      ),
    )));
  }

  Widget recordCard() {
    return const Card();
  }
}
