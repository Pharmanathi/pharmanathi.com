// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyMap extends StatelessWidget {
  const MyMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            color: Color(0xFF6F7ED7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 70, left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4, left: 10),
                        child: GestureDetector(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'Map',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.tune,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 25, bottom: 25, left: 25, right: 25),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by category',
                      suffixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Color.fromARGB(255, 179, 186, 229),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                    ),
                    onChanged: (value) {
                      // Handle search functionality here
                    },
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          //   Container(
          //   height: 400, // Set the desired height
          //   width: double.infinity,
          //   child: MapScreen(),
          // ),
        ],
      ),
    );
  }
}
