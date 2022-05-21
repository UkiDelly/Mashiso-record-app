import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../google_map.dart';
import '../models/timeInOut.dart';
import '../preferences.dart';
import 'Record.dart';
import 'login.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  String name;
  Home({Key? key, required this.name}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> with AutomaticKeepAliveClientMixin {
  //
  PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  late bool? status = false;
  dynamic address = "";
  DateTime time = DateTime.now();
  TimeInOut timeInOut = TimeInOut(LoginPreferences.getUserId()!);

  //*Google map
  late GoogleMapController mapController;

  //*Get the current location
  getCurrentLocation() async {
    address = await Geolocator.getCurrentPosition();
  }

  //*Change the page
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

    //bring the last state of the time in/out
    status = LoginPreferences.getInOut();

    //get the current location
    address = getCurrentLocation();
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
            // ignore: use_build_context_synchronously
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
                        onTap: status == false
                            ? () {
                                //get the current location
                                getCurrentLocation();

                                setState(() {
                                  //set the status to time out
                                  status = true;

                                  //get the current time
                                  time = DateTime.now();

                                  address;
                                });

                                timeInOut.timeInUpload(
                                    widget.name, time, address);
                                LoginPreferences.setInOut(status!);
                              }
                            : null,
                        child: const Center(
                            child: Text(
                          "IN",
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
                        onTap: status == true
                            ? () async {
                                //get the current location
                                getCurrentLocation();

                                setState(() {
                                  //set the status to time out
                                  status = false;

                                  //get the current time
                                  time = DateTime.now();
                                });

                                //send data to firebase
                                timeInOut.timeOutUpLoad(time, address);
                                await LoginPreferences.setInOut(status!);
                              }
                            : null,
                        child: const Center(
                            child: Text(
                          "OUT",
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
            GoogleMapWidget(),
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
