import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';
import 'package:work_record_app/Record.dart';
import 'package:work_record_app/login.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:work_record_app/preferences.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  String name;
  Home({Key? key, required this.name}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  //
  PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  bool timeIn = false;

  //Google map
  late GoogleMapController mapController;
  final LatLng _position = const LatLng(10.682024, 122.954228);

  //Location
  Location location = Location();

  // set the location when the map created
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // listen for the location
    location.onLocationChanged.listen((l) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 70)));
    });
  }

  //Get the current location
  getCurrentLocation() async {
    final currentLocation = await location.getLocation();
    //TODO: send firebase the location info
  }

  //Service and permission
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  //check the permission
  checkPermission() async {
    //check the service in enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    //check the permission is enabled
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }

    setState(() {
      _serviceEnabled;
      _permissionGranted;
    });
  }

  //
  _createData() async {
    final userCollection =
        await FirebaseFirestore.instance.collection('employee').get();

    //get the data
    var data = userCollection.docs[0].exists;

    print(data);
  }

  //Change the page
  _changePage(int index) {
    setState(() {
      currentIndex = index;
    });
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
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
                    child: const Login(), type: PageTransitionType.fade));
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
                      const Text(
                        "Name:",
                        style: TextStyle(fontSize: 25),
                      ),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                widget.name,
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              )))
                    ],
                  ),
                )),

            //
            const SizedBox(
              height: 30,
            ),

            //Time in/out
            Card(
              elevation: 5,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 250,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Time in
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                          color: (timeIn == false)
                              ? Colors.transparent
                              : const Color(0xffFDBF05),
                          border: Border.all(color: Colors.black, width: 5),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(100))),
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        onTap: () {
                          print("Time in");
                          setState(() {
                            timeIn = true;
                          });
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
                          color: (timeIn == false)
                              ? const Color(0xffFDBF05)
                              : Colors.transparent,
                          border: Border.all(color: Colors.black, width: 5),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(100))),
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        onTap: () async {
                          print("Time out");
                          setState(() {
                            timeIn = false;
                          });
                          var _address = await getCurrentLocation();
                          print(_address);
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
              height: 30,
            ),

            //Google Map
            _googleMap(),

            // test
          ],
        ),
      ),
    );
  }

  Widget _googleMap() {
    return Container(
      width: 500,
      height: 400,
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: const Color(0xffFDBF05)),
          borderRadius: const BorderRadius.all(Radius.circular(25))),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20)),
        child: GoogleMap(
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _position, zoom: 70),
          myLocationEnabled: true,
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
