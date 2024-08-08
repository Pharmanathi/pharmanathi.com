// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/api_helpers.dart';
import '../components/UserProvider.dart';
import '../components/navigation_bar.dart';

class ProfileSetting extends StatefulWidget {
  const ProfileSetting({super.key});

  @override
  State<ProfileSetting> createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {

  int _selectedIndex = 3;

  //method to handle navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: Icon(
                    Icons.warning,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Log Out?',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Are you sure you want to log-out?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle log-out here
                // _signOut();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    String alteredname = ApiHelper.toTitleCase('${userProvider.name}');

    return Scaffold(
      body: Expanded(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 290,
                  color: Color(0xFF6F7ED7),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Padding(
                          //   padding:
                          //       const EdgeInsets.only(right: 10, left: 10),
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       Navigator.pop(context);
                          //     },
                          //     child: const Icon(
                          //       Icons.arrow_back,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(top: 60,left: 90, right:60,bottom: 60 ),
                            child: Text(
                              'Profile Settings',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
            Expanded(
              child: Positioned(
                top: 110,
                left: 30,
                right: 30,
                bottom: 3,
                child: Container(
                  color: Color(0xFFF7F9FC),
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: Column(
                      children: [
                        //profile picture and details
                        Container(
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(userProvider.picture ?? ''),
                                radius: 80,
                              ),
                              //doctor's name
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  alteredname,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              //profission
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  alteredname,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        buildDivider(),

                        //account setting...........
                        GestureDetector(
                          onTap: () async {},
                          child: Container(
                              child: buildSectionTile(
                                  'Account settings', Icons.border_color)),
                        ),
                        buildDivider(),

                        //notifications.............................
                        GestureDetector(
                          onTap: () {
                            //handle
                          },
                          child: Container(
                              child: buildSectionTile(
                                  'Notification', Icons.notifications)),
                        ),
                        buildDivider(),

                        //support....................
                        GestureDetector(
                          onTap: () {
                            //handle
                          },
                          child: Container(
                              child:
                                  buildSectionTile('Support ', Icons.help)),
                        ),
                        buildDivider(),

                        //private policy .............................
                        // Container(
                        //   child: Container(
                        //       child: buildSectionTile(
                        //           'Private Policy', Icons.gpp_maybe)),
                        // ),
                        // buildDivider(),

                        // log out........................
                        GestureDetector(
                          onTap: () {
                            _showModal(context);
                          },
                          child: Container(
                              child:
                                  buildSectionTile('LogOut', Icons.logout)),
                        ),
                        buildDivider()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
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
    return Container(
      width: 500,
      child: Divider(
        color: Colors.grey,
        thickness: 0.5,
      ),
    );
  }
}
