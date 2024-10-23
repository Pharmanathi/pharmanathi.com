
// // ignore_for_file: prefer_const_constructors, prefer_collection_literals

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';



// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController mapController;

//   final LatLng initialLocation = LatLng(37.7749, -122.4194);

//   @override
//   Widget build(BuildContext context) {
//     return GoogleMap(
//       initialCameraPosition: CameraPosition(
//         target: initialLocation,
//         zoom: 13.0,
//       ),
//       onMapCreated: (GoogleMapController controller) {
//         mapController = controller;
//       },
//       markers: <Marker>[
//         Marker(
//           markerId: MarkerId('Your Location'),
//           position: initialLocation,
//           infoWindow: InfoWindow(title: 'Your Location'),
//         ),
//       ].toSet(),
//     );
//   }
// }
