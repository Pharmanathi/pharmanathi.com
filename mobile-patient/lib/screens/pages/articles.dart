// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';


class MyArticles extends StatefulWidget {
  const MyArticles({super.key});

  @override
  State<MyArticles> createState() => _MyArticlesState();
}

class _MyArticlesState extends State<MyArticles> {
   int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          
        ],
      ),
      //  CustomBottomNavigationBar
      // bottomNavigationBar: CustomBottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }
}