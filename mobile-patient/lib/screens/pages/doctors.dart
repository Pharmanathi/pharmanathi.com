// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_import, sized_box_for_whitespace

import 'package:client_pharmanathi/screens/components/doctors/doctor_data.dart';
import 'package:client_pharmanathi/screens/components/doctors/doctor_tile.dart';
import 'package:client_pharmanathi/screens/components/navigation_bar.dart';
import 'package:client_pharmanathi/services/doctor_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Doctors extends StatefulWidget {
  const Doctors({super.key});

  // Linking data to the doctors details file

  @override
  State<Doctors> createState() => _DoctorsState();
}

class _DoctorsState extends State<Doctors> {
  TextEditingController searchController = TextEditingController();
  List<DoctorDetail> filteredDoctorDetails = [];
  List<DoctorDetail> doctorDetails = [];
  bool isSearchFieldVisible = false;
  int selectedButtonIndex = 0;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadDoctors(context);
  }

  Future<void> _loadDoctors(BuildContext context) async {
  try {
    final List<DoctorDetail> loadedDoctors = await fetchDoctors(context);
    setState(() {
      doctorDetails = loadedDoctors;
      filteredDoctorDetails = loadedDoctors;
    });
  } catch (error) {
    // Handle any errors that occur during the loading process
    print('Error loading doctors: $error');
    //* show an error message to the user
    // setState(() {
    //   errorMessage = 'Failed to load doctors. Please try again later.';
    // });
  }
}



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void filterDoctors(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        // If the search text is empty, show all doctors
        filteredDoctorDetails = doctorDetails;
      } else {
        // Otherwise, filter based on the search text
        filteredDoctorDetails = doctorDetails
            .where((doctor) =>
                doctor.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();

        print("Filtered Doctors: ${filteredDoctorDetails.length}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            // color: Color(0xFF6F7ED7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(
                          'All Doctors',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20, top: 50),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSearchFieldVisible = !isSearchFieldVisible;
                                });
                              },
                              child: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(right: 20),
                          //   child: Icon(
                          //     Icons.pin_drop_sharp,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          isSearchFieldVisible
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 3.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Doctors',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      filterDoctors(value);
                    },
                  ),
                )
              : Container(),

          //container  for buttons

          Row(
            children: [
              //personal info button
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedButtonIndex = 0;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        // border: Border(
                        //     bottom: BorderSide(
                        //       color: selectedButtonIndex == 0
                        //           ? Color(0xFF6F7ED7)
                        //           : Colors.transparent,
                        //       width: 3.5,
                        //     ),
                        //     ),
                        ),
                    // child: Padding(
                    //   padding: const EdgeInsets.only(right: 50),
                    //   child: Text(
                    //     'All Doctors',
                    //     style: TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //       color: selectedButtonIndex == 0
                    //           ? Color(0xFF6F7ED7)
                    //           : Colors.grey,
                    //     ),
                    //   ),
                    // ),
                  ),
                ),
              ),
              //health info button
              // Expanded(
              //   child: InkWell(
              //     onTap: () {
              //       setState(() {
              //         selectedButtonIndex = 1;
              //       });
              //     },
              //     child: Container(
              //       padding: EdgeInsets.symmetric(vertical: 15.0),
              //       alignment: Alignment.center,
              //       decoration: BoxDecoration(
              //         border: Border(
              //           bottom: BorderSide(
              //             color: selectedButtonIndex == 1
              //                 ? Color(0xFF6F7ED7)
              //                 : Colors.transparent,
              //             width: 3.5,
              //           ),
              //         ),
              //       ),
              //       child: Padding(
              //         padding: const EdgeInsets.only(right: 50),
              //         child: Text(
              //           'My Doctors',
              //           style: TextStyle(
              //             fontWeight: FontWeight.bold,
              //             color: selectedButtonIndex == 1
              //                 ? Color(0xFF6F7ED7)
              //                 : Colors.grey,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          // Container(
          //   color: Colors.grey[100],
          //   width: double.infinity,
          //   height: 50,
          //   // color: Color(0xFF6F7ED7),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Text(
          //               'Doctors List',
          //               style: TextStyle(
          //                 color: Colors.black,
          //                 fontSize: 12.0,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             Row(
          //               children: [
          //                 Text(
          //                   'Grid View',
          //                   style: TextStyle(
          //                     color: Colors.grey,
          //                     fontSize: 12.0,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //                 SizedBox(
          //                   width: 10,
          //                 ),
          //                 Padding(
          //                   padding: const EdgeInsets.only(right: 20),
          //                   child: Icon(
          //                     Icons.view_comfy,
          //                     color: Colors.grey,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          selectedButtonIndex == 0
              ? Expanded(
                  child: FutureBuilder<List<DoctorDetail>>(
                    future:
                        fetchDoctors(context), // Use fetchDoctors function to fetch the list of doctors
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        // Handle error
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        // Handle no data case
                        return Center(
                          child: Text('No doctors found.'),
                        );
                      } else {
                        // Display the list of doctors using ListView.builder
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return CustomDoctorCard(
                              doctorDetails: snapshot.data![index],
                            );
                          },
                        );
                      }
                    },
                  ),
                )
              : Container(),
        ],
      ),
      // CustomBottomNavigationBar
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
