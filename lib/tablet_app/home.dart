import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ndialog/ndialog.dart';
import 'package:work_record_app/employee_app/login.dart';
import 'package:work_record_app/mobile_app/home.dart';

final recordState = GlobalKey<__RecordState>();

class TabletHome extends StatelessWidget {
  const TabletHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Column(
        children: [
          //
          const SizedBox(
            height: 10,
          ),

          //Logo
          Center(
              child: Image.asset(
            'assets/mashiso.png',
            height: 150,
          )),

          //
          const SizedBox(
            height: 20,
          ),

          // Body
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _EmployeeList(),
                const VerticalDivider(
                  thickness: 3,
                ),
                _Record(
                  key: recordState,
                )
              ],
            ),
          )
        ],
      )),
    );
  }
}

class _EmployeeList extends StatefulWidget {
  const _EmployeeList({Key? key}) : super(key: key);

  @override
  State<_EmployeeList> createState() => _EmployeeListState();
}

class _EmployeeListState extends State<_EmployeeList> {
  int numOfEmployees = 0;
  List nameList = [], idList = [];

  //get employee list
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    nameList = [];
    idList = [];
    numOfEmployees = 0;
    getEmployeeList();
  }

  @override
  void initState() {
    super.initState();
    getEmployeeList();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Column(
        children: [
          //Employee and add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Spacer(),
              Text(
                "Employee",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              Spacer(
                flex: 6,
              ),

              //Add Employee
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.person_add),
              //   iconSize: 40,
              //   color: mainColor,
              //   splashColor: Colors.transparent,
              //   highlightColor: Colors.transparent,
              // ),
              // const Spacer(),
            ],
          ),
          const SizedBox(
            height: 10,
          ),

          // Employee List
          Expanded(
              child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: ListView.builder(
              itemCount: numOfEmployees,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  color: mainColor,
                  child: ListTile(
                    title: Center(
                      child: Text(
                        "${nameList[index]}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w500),
                      ),
                    ),
                    onTap: () {
                      //* show records

                      recordState.currentState!._showRecord(idList[index]);
                    },
                    onLongPress: () => NAlertDialog(
                      content: const SizedBox(
                          height: 70,
                          child: Center(
                            child: Text(
                              "Are you sure you want to delete this employee?",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                          )),
                      actions: [
                        TextButton(
                            style: const ButtonStyle(
                                splashFactory: NoSplash.splashFactory),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black),
                            )),

                        //* Delete employee
                        TextButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('employee')
                                  .doc(idList[index])
                                  .delete();

                              //rebuild the widget
                              didChangeDependencies();
                              Navigator.pop(context);
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
          ))
        ],
      ),
    );
  }
}

class _Record extends StatefulWidget {
  const _Record({Key? key}) : super(key: key);

  @override
  State<_Record> createState() => __RecordState();
}

class __RecordState extends State<_Record> {
  bool isClicked = false;
  String employeeId = "empty";
  List recordList = [];
  int recordListLength = 0;
  String text = "";

  _showRecord(_employeeId) async {
    employeeId = _employeeId;
    isClicked = true;
    final _record = await FirebaseFirestore.instance
        .collection('employee')
        .doc(employeeId)
        .collection('record')
        .orderBy('IN', descending: true)
        .get();

    if (_record.docs.isEmpty) {
      isClicked = false;
      text = "No Records found!";
    }

    setState(() {
      recordList = _record.docs;
      recordListLength = _record.docs.length;
      employeeId;
    });
  }

  @override
  void didChangeDependencies() {
    _showRecord(employeeId);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: isClicked
            ? ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recordListLength,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) {
                  return const VerticalDivider(
                    indent: 10,
                    endIndent: 10,
                    thickness: 3,
                  );
                },

                // Show the Record
                itemBuilder: (BuildContext context, int index) {
                  //get time
                  DateTime _timeInDate = recordList[index]['IN'].toDate();
                  DateTime? _timeOutDate;
                  try {
                    _timeOutDate = recordList[index]['OUT'].toDate();
                  } catch (e) {
                    print(e);
                    _timeOutDate = null;
                  }

                  String _timeIN = DateFormat.jm().format(_timeInDate);
                  String _timeOUT = '';
                  if (_timeOutDate != null) {
                    _timeOUT = DateFormat.jm().format(_timeOutDate);
                  }
                  //get date
                  String _date = DateFormat.yMMMMd('en_US')
                      .format(recordList[index]['IN'].toDate());

                  //get how many work
                  String totalWork = '';
                  if (_timeOutDate != null) {
                    totalWork =
                        "${_timeOutDate.difference(_timeInDate).inHours} hr ${_timeOutDate.difference(_timeInDate).inMinutes.remainder(60)} min";
                  }

                  //get location
                  GeoPoint _locationIN = recordList[index]['locationIN'];
                  late GeoPoint? _locationOUT;
                  try {
                    _locationOUT = recordList[index]['locationOUT'];
                  } catch (e) {
                    _locationOUT = null;
                  }
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: mainColor, width: 3)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      splashFactory: NoSplash.splashFactory,
                      //* Alert before delete record
                      onLongPress: () => NAlertDialog(
                        content: const SizedBox(
                          height: 70,
                          child: Center(
                              child: Text(
                            "Are you sure to delete his record?",
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
                                Navigator.of(context).pop();
                                didChangeDependencies();

                                await FirebaseFirestore.instance
                                    .collection('employee')
                                    .doc(employeeId)
                                    .collection('record')
                                    .doc(recordList[index].id)
                                    .delete();
                              },
                              child: const Text(
                                "Ok",
                                style: TextStyle(color: Colors.red),
                              )),
                        ],
                      ).show(context),
                      child: Container(
                        // width: 500,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xffFDBF05), width: 3)),
                        child: Column(
                          children: [
                            //* Time in time and location
                            Text(
                              _date,
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            //*Time in/out and map
                            timeInOutAndMap(index, _timeIN, _timeOUT,
                                _locationIN, _locationOUT),

                            //* Total work time
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: const Color(0xffFDBF05),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                "Total work: $totalWork",
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w300),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(text),
              ),
      ),
    );
  }

  Widget timeInOutAndMap(
    int index,
    String timeIn,
    String? timeOut,
    GeoPoint locationIN,
    GeoPoint? locationOUT,
  ) {
    const MarkerId timeInMarker = MarkerId("IN");
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //*Time in and map
        Column(
          children: [
            Text(
              "IN: $timeIn",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            Container(
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(20)),
                width: 250,
                height: 370,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                  child: GoogleMap(
                      scrollGesturesEnabled: false,
                      zoomControlsEnabled: false,
                      markers: {
                        Marker(
                            markerId: timeInMarker,
                            position: LatLng(
                                locationIN.latitude, locationIN.longitude))
                      },
                      mapType: MapType.normal,
                      mapToolbarEnabled: false,
                      initialCameraPosition: CameraPosition(
                          target:
                              LatLng(locationIN.latitude, locationIN.longitude),
                          zoom: 20)),
                )),
          ],
        ),

        //*Time out and map
        SizedBox(
          child: timeOut != ''
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "OUT: $timeOut",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w400),
                    ),

                    //map
                    Container(
                        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(20)),
                        width: 250,
                        height: 370,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20)),
                          child: GoogleMap(
                              scrollGesturesEnabled: false,
                              zoomControlsEnabled: false,
                              markers: {
                                Marker(
                                    markerId: timeInMarker,
                                    position: LatLng(locationOUT!.latitude,
                                        locationOUT.longitude))
                              },
                              mapType: MapType.normal,
                              mapToolbarEnabled: false,
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(locationOUT.latitude,
                                      locationOUT.longitude),
                                  zoom: 20)),
                        )),
                  ],
                )
              : null,
        )
      ],
    );
  }
}
