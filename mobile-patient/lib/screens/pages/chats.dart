// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:client_pharmanathi/screens/components/chats/chat_data.dart';
import 'package:client_pharmanathi/screens/components/chats/chat_tile.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:flutter/services.dart';

class Mychats extends StatefulWidget {
  const Mychats({super.key});

  Future<List<ChatsDetails>> loadChats() async {
  // Load the JSON file
  String jsonString = await rootBundle.loadString('assets/sample.json');
  // Parse the JSON data
  List<dynamic> jsonList = convert.jsonDecode(jsonString)['chats_details'];
  // Create a list of ChatsDetails objects
  List<ChatsDetails> chatsDetails = jsonList
      .map((json) => ChatsDetails(
            name: json['name'] ?? '',
            time: json['time'] ?? '',
            details: json['details'] ?? '',
            imageUrl: json['imageUrl'] ?? '',
            status: json['status'] ?? '',
          ))
      .toList();

  return chatsDetails;
}


  @override
  State<Mychats> createState() => _MychatsState();
}

class _MychatsState extends State<Mychats> {
  // int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      // _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 210,
            color: Color(0xFF6F7ED7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 70, left: 20, right: 20,bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chats',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 25, bottom: 0, left: 25, right: 25),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search  massege',
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
          Expanded(
            child: FutureBuilder<List<ChatsDetails>>(
              future: widget.loadChats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show a loading indicator while data is loading
                } else if (snapshot.hasError) {
                  // print('Error loading data: ${snapshot.error}');
                  // print('Stack trace: ${snapshot.stackTrace}');
                  return Center(
                    child: Text('Error loading data. Please try again later.'),
                  );
                } else {
                  List<ChatsDetails> chatsDetails = snapshot.data!;
                  return ListView.builder(
                    itemCount: chatsDetails.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CustomCard(chatsDetails: chatsDetails[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      //flouting button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action here
        },
        child: const Icon(Icons.edit),
      ),
      // CustomBottomNavigationBar
      // bottomNavigationBar: CustomBottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }
}
