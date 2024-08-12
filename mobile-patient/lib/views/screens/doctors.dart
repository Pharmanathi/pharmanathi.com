// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_import, sized_box_for_whitespace

import 'package:client_pharmanathi/Repository/doctor_repository.dart';
import 'package:client_pharmanathi/model/doctor_data.dart';
import 'package:client_pharmanathi/views/widgets/doctor_tile.dart';
import 'package:client_pharmanathi/screens/components/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Doctors extends StatefulWidget {
  const Doctors({super.key});

  @override
  State<Doctors> createState() => _DoctorsState();
}

class _DoctorsState extends State<Doctors> {
  TextEditingController searchController = TextEditingController();
  List<Doctor> filteredDoctorDetails = [];
  List<Doctor> doctorDetails = [];
  bool isSearchFieldVisible = false;
  int selectedButtonIndex = 0;
  int _selectedIndex = 1;
  bool isLoading = true;
  late DoctorRepository _doctorRepository;

  @override
  void initState() {
    super.initState();
    _doctorRepository = context.read<DoctorRepository>();
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    try {
      List<Doctor> fetchDoctors = await _doctorRepository.fetchDoctors(context);
      print("Fetched Doctors: ${fetchDoctors.length}"); // Debug statement
      setState(() {
        doctorDetails = fetchDoctors;
        filteredDoctorDetails = fetchDoctors; // Initialize filtered list
        isLoading = false;
      });
    } catch (error) {
      print('Error loading doctors: $error');
      // Handle error as needed
    }
  }

  // Handles navigation bar item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //* Filters the doctors list based on the search text
  void filterDoctors(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        //* If the search text is empty, show all doctors
        filteredDoctorDetails = doctorDetails;
      } else {
        // Otherwise, filter based on the search text
        filteredDoctorDetails = doctorDetails
            .where((doctor) => doctor.doctorName
                .toLowerCase()
                .contains(searchText.toLowerCase()))
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
                  child: SingleChildScrollView(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : filteredDoctorDetails.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/nodata.png',
                                      width: 120,
                                      height: 120,
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'No doctors available',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredDoctorDetails.length,
                                itemBuilder: (context, index) {
                                  final data = filteredDoctorDetails[index];

                                  return CustomDoctorCard(
                                    doctor: data,
                                  );
                                },
                              ),
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
