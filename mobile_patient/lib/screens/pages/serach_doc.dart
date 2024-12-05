// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, sized_box_for_whitespace

import 'dart:convert';

import 'package:patient/screens/components/recent_card.dart';
import 'package:patient/screens/components/specialists/data.dart';
import 'package:patient/screens/components/specialists/tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchDoctor extends StatefulWidget {
  const SearchDoctor({super.key});

  @override
  State<SearchDoctor> createState() => _SearchDoctorState();
}

class _SearchDoctorState extends State<SearchDoctor> {
  Future<List<SpecialistDetails>> loadSpecialist() async {
    // Load the JSON file
    String jsonString = await rootBundle.loadString('assets/sample.json');

    // Parse the JSON data
    List<dynamic> jsonList = jsonDecode(jsonString)['recent_search'];

    // Create a list of SpecialistDetails objects
    List<SpecialistDetails> specialistDetails = jsonList.map((json) {
      return SpecialistDetails(
        title: json['title'] ?? '',
        count: json['count'] ?? '',
      );
    }).toList();

    return specialistDetails;
  }

  Future<List<CardData>> loadRecentSearch() async {
    String data =
        await DefaultAssetBundle.of(context).loadString('assets/sample.json');
    Map<String, dynamic> jsonData = json.decode(data);
    List<dynamic> jsonList = jsonData['recent_search'];
    List<dynamic> firstFourItems = jsonList.take(4).toList();
    return firstFourItems.map((item) => CardData.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 200,
            color: Color(0xFF6F7ED7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 10, left: 10, top: 70),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 70, left: 75),
                      child: Text(
                        'Category',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 0, bottom: 25, left: 25, right: 25),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search....',
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(
                        'Recent',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: loadRecentSearch(),
                  builder: (context, AsyncSnapshot<List<CardData>> snapshot) {
                    if (snapshot.hasData) {
                      return buildCardRows(snapshot.data!);
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading data'));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 5, left: 20, bottom: 10, right: 20),
                  child: Row(
                    children: [
                      Text(
                        'All Specialities',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<SpecialistDetails>>(
                    future: loadSpecialist(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child:
                              CircularProgressIndicator(), // Show a loading indicator while waiting for data.
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'Error: ${snapshot.error}'), // Show an error message if data fetching fails.
                        );
                      } else if (snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                              'No data available'), // Show a message when no data is available.
                        );
                      } else {
                        // Data has been fetched successfully, display it.
                        List<SpecialistDetails> specialistDetails =
                            snapshot.data!;
                        return ListView.builder(
                          itemCount: specialistDetails.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SpecialistCard(
                                specialistDetails: specialistDetails[index]);
                          },
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  //generating the cards based on a list of data

  Widget buildCardRows(List<CardData> cardData) {
    List<Widget> rows = [];
    for (int i = 0; i < cardData.length; i += 2) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildCard(cardData[i]),
            // SizedBox(width: 2.0),
            if (i + 1 < cardData.length) buildCard(cardData[i + 1]),
          ],
        ),
      );
      rows.add(SizedBox(height: 10.0));
    }
    return Column(
      children: rows,
    );
  }

  Widget buildCard(CardData data) {
    return Container(
      width: 170,
      margin: EdgeInsets.all(8.0),
      child: TopBorderCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Text(
                  data.title,
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.person_4,
                        color: Colors.grey,
                        size: 12,
                      ),
                      Row(
                        children: [
                          Text(
                            data.count,
                            style: TextStyle(fontSize: 10.0),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Spacialist',
                            style: TextStyle(fontSize: 10.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        borderColor: data.borderColor,
        backgroundColor: data.backgroundColor,
      ),
    );
  }
}
