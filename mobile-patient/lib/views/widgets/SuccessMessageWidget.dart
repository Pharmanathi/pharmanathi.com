// import 'package:client_pharmanathi/config/color_const.dart';
// import 'package:flutter/material.dart';

// class SuccessMessageWidget {
//   static void show(
//     BuildContext context, {
//     required String message,
//     Duration duration = const Duration(seconds: 300),
//     Color backgroundColor = Pallet.PURE_WHITE,
//   }) {
//     final overlay = Overlay.of(context);

//     late OverlayEntry overlayEntry;

//     overlayEntry = OverlayEntry(
//       builder: (context) => Material(
//         color: const Color.fromARGB(255, 58, 58, 62),
//         child: Center(
//           child: Container(
//             width: 350,
//             height: 450,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: backgroundColor,
//               borderRadius: BorderRadius.circular(5.0),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.check_circle_outline,
//                   color: Pallet.SUCCESS,
//                   size: 52.0,
//                 ),
//                 const SizedBox(height: 60.0),
//                 const Text(
//                   'SUCCESS!',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 28),
//                 ),
//                 const SizedBox(height: 10.0),
//                 Text(
//                   message,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.black, fontSize: 16),
//                 ),
//                 const SizedBox(height: 60.0),
//                 Container(
//                   width: 250,
//                   height: 35,
//                   decoration: BoxDecoration(
//                     color: Pallet.SUCCESS,
//                     borderRadius: BorderRadius.circular(5.0),
//                   ),
//                   child: TextButton(
//                     onPressed: () {
//                       overlayEntry.remove();
//                     },
//                     child: const Text(
//                       'Got It',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//     //* Insert the overlay entry
//     overlay.insert(overlayEntry);

//     //* Remove the overlay after the specified duration
//     Future.delayed(duration, () {
//       overlayEntry.remove();
//     });
//   }
// }
