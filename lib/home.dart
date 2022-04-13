import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';
import 'package:work_record_app/Record.dart';
import 'package:work_record_app/google_map.dart';
import 'package:work_record_app/login.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:work_record_app/preferences.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  Location location;
  String name;
  Home({Key? key, required this.name, required this.location})
      : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> with AutomaticKeepAliveClientMixin {
  //
  PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  late bool? status = false;
  var address;
  DateTime time = DateTime.now();

  //*Google map
  late GoogleMapController mapController;
  final LatLng _position = const LatLng(10.682024, 122.954228);

  //*Location
  Location location = Location();

  //*Get the current location
  getCurrentLocation() {
    location.onLocationChanged.listen((location) {
      setState(() {
        address = location;
      });
    });
  }

  // //*Service and permission
  // late bool _serviceEnabled;
  // late PermissionStatus _permissionGranted;

  // //*check the permission
  // checkPermission() async {
  //   //check the service in enabled
  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //   }

  //   //*check the permission is enabled
  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //   }

  //   setState(() {
  //     _serviceEnabled;
  //     _permissionGranted;
  //   });
  // }

  //*Change the page
  _changePage(int index) {
    setState(() {
      currentIndex = index;
    });
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }

  //*Send Firebase
  timeInUpload(var time, var address) async {
    var _userId = LoginPreferences.getUserId();
    final _employee = await FirebaseFirestore.instance
        .collection('employee')
        .doc(_userId)
        .collection('record')
        .add({
      'status': "IN",
      'time': Timestamp.fromDate(time),
      'location': GeoPoint(address.latitude, address.longitude)
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

  timeOutUpLoad() async {
    var _userId = LoginPreferences.getUserId();
    final _employee = await FirebaseFirestore.instance
        .collection('employee')
        .doc(_userId)
        .collection('record')
        .add({
      'status': "OUT",
      'time': Timestamp.fromDate(time),
      'location': GeoPoint(address.latitude, address.longitude)
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

  @override
  void initState() {
    super.initState();
    // check permission
    // WidgetsBinding.instance?.addPostFrameCallback((_) => checkPermission());
    location = widget.location;

    //bring the last state of the time in/out
    status = LoginPreferences.getInOut();

    //get the current location
    address = "Not press yet";
    getCurrentLocation();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: PageView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: [_home(), const Record()],
        ),
      ),

      //Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        currentIndex: currentIndex,
        onTap: (index) async {
          if (index == 2) {
            //Logout if the logout button is pressed
            await LoginPreferences.saveUserId("empty_user_id");
            Navigator.pushReplacement(
                context,
                PageTransition(
                    child: Login(
                      location: widget.location,
                    ),
                    type: PageTransitionType.fade));
          }
          _changePage(index);
        },
        items: const [
          // Home Button
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Record",
            icon: Icon(
              Icons.bar_chart,
            ),
          ),
          BottomNavigationBarItem(
            label: "Logout",
            icon: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }

  // Home screen
  Widget _home() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //
            const SizedBox(
              height: 50,
            ),
            //Logo
            Image.asset(
              'assets/mashiso.png',
              height: 150,
            ),

            const SizedBox(height: 30),

            //Name
            Card(
                elevation: 5,
                color: const Color(0xffFDBF05),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                )),

            //
            const SizedBox(
              height: 15,
            ),

            //Time in/out
            Card(
              elevation: 5,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Container(
                margin: const EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width * 0.9,
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Time in
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                          color: (status == true)
                              ? const Color(0xffFDBF05)
                              : Colors.transparent,
                          border: Border.all(color: Colors.black, width: 5),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(100))),
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        onTap: () async {
                          //get the current location
                          getCurrentLocation();

                          setState(() {
                            //set the status to time out
                            status = true;

                            //get the current time
                            time = DateTime.now();

                            address;
                          });

                          timeInUpload(time, address);
                          await LoginPreferences.setInOut(status!);
                        },
                        child: const Center(
                            child: Text(
                          "Time in",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        )),
                      ),
                    ),
                    const VerticalDivider(
                      indent: 20,
                      endIndent: 20,
                      color: Colors.black,
                    ),

                    //Time out
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                          color: (status != true)
                              ? const Color(0xffFDBF05)
                              : Colors.transparent,
                          border: Border.all(color: Colors.black, width: 5),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(100))),
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        onTap: () async {
                          //get the current location
                          getCurrentLocation();

                          setState(() {
                            //set the status to time out
                            status = false;

                            //get the current time
                            time = DateTime.now();
                          });

                          //send data to firebase
                          timeOutUpLoad();
                          await LoginPreferences.setInOut(status!);
                        },
                        child: const Center(
                            child: Text(
                          "Time out",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        )),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),

            //Google Map
            GoogleMapWidget(location: location),
          ],
        ),
      ),
    );
  }
}

//Remove Glow
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
