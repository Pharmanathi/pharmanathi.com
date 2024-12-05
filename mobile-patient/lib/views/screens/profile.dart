// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace, use_super_parameters
import 'package:client_pharmanathi/views/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/components/UserProvider.dart';
import 'profile_settings.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({
    Key? key,
  }) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  // int _selectedIndex = 3;

  // //method to handle navigation
  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Color(0xFF6F7ED7),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(50),
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  height: 300,
                ),
              ],
            ),
            Positioned(
              top: 110,
              left: 30,
              right: 30,
              bottom: 2,
              child: Container(
                color: Color(0xFFF7F9FC),
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      //profile picture and details
                      GestureDetector(
                        onTap: () {
                          // Navigate to the profile settings page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileSetting()),
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(userProvider.picture ?? ''),
                              radius: 30,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 200,
                                  child: Text(
                                    '${userProvider.name}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    '20 years',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 500,
                        child: Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF6F7ED7),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.person,
                                    size: 35,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Saved',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'Doctors',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.note,
                                    size: 35,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Saved',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'Articles',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.favorite,
                                    size: 35,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Health',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'Diary',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                     buildDivider(),
                      //account information...........
                      GestureDetector(
                        onTap: () {
                          //handle
                        },
                        child: Container(
                            child:
                                buildSectionTile('Appointments', Icons.person)),
                      ),

                     buildDivider(),
                      //pill reminder.............................
                      GestureDetector(
                        onTap: () {
                          //handle
                        },
                        child: Container(
                            child: buildSectionTile(
                                'Pill Reminder', Icons.cast_for_education_sharp)),
                      ),
                     buildDivider(),
                      //My doctors....................
                      GestureDetector(
                        onTap: () {
                          //handle
                        },
                        child: Container(
                            child: buildSectionTile('My Doctors', Icons.info)),
                      ),
                     buildDivider(),
                      //Manage Schedule.............................
                      GestureDetector(
                        onTap: () {

                        },
                        //insureance plan
                        child: Container(
                            child: buildSectionTile(
                                'Insurence Plan', Icons.calendar_month)),
                      ),
                      buildDivider()
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      // bottomNavigationBar: CustomBottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }

  Widget buildSectionTile(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(69, 173, 182, 241),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(10),
                child: Icon(
                  icon,
                  color: Color(0xFF6F7ED7),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.arrow_forward_ios,
                 size: 12.0,
                color: Color(0xFF6F7ED7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return SizedBox(
      width: 500,
      child: Divider(
        color: Colors.grey,
        thickness: 0.5,
      ),
    );
  }
}
