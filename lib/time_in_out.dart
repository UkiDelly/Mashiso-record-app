import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:work_record_app/Record.dart';
import 'package:work_record_app/login.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TimeInOut extends StatefulWidget {
  const TimeInOut({Key? key}) : super(key: key);

  @override
  State<TimeInOut> createState() => _TimeInOutState();
}

class _TimeInOutState extends State<TimeInOut> {
  //
  PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  bool timeIn = false;
  late GoogleMapController mapController;
  //Google map
  // late GoogleMapController mapController;
  // final LatLng _center = const LatLng(45.521563, -122.677433);
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

  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: PageView(
          controller: pageController,
          children: [_home(), const Record()],
        ),
      ),

      //Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 2) {
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
                    children: const [
                      Text(
                        "Name:",
                        style: TextStyle(fontSize: 25),
                      ),
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "{Name}",
                                style: TextStyle(
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
                      width: 200,
                      height: 200,
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
                              fontWeight: FontWeight.bold, fontSize: 40),
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
                      width: 200,
                      height: 200,
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
                        onTap: () {
                          print("Time out");
                          setState(() {
                            timeIn = false;
                          });
                        },
                        child: const Center(
                            child: Text(
                          "Time out",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 40),
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
            _map()
          ],
        ),
      ),
    );
  }

  Widget _map() {
    return Container(
      width: 500,
      height: 500,
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: const Color(0xffFDBF05)),
          borderRadius: const BorderRadius.all(Radius.circular(25))),
      // child:
      // GoogleMap(
      //   onMapCreated: _onMapCreated,
      //   initialCameraPosition: CameraPosition(target: _center, zoom: 11),
      // ),
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
