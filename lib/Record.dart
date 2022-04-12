import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Record extends StatefulWidget {
  const Record({Key? key}) : super(key: key);

  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  late List data = [];
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
      child: Text("$data"),
    )));
  }
}
