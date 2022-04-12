import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatefulWidget {
  var location;
  GoogleMapWidget({Key? key, required this.location}) : super(key: key);

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  //Google map
  late GoogleMapController mapController;
  final LatLng _position = const LatLng(10.682024, 122.954228);

  // set the location when the map created
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // listen for the location
    widget.location.onLocationChanged.listen((l) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 70)));
    });
  }

  @override
  Widget build(BuildContext context) {
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
