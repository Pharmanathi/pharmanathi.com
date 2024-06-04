// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:client_pharmanathi/screens/components/chats/chat_data.dart';
import 'package:flutter/material.dart';


class CustomCard extends StatelessWidget {
  final ChatsDetails chatsDetails;

  CustomCard({required this.chatsDetails});
  @override
  Widget build(BuildContext context) {

     String truncateText(String text, int maxLength) {
    if (text.length > maxLength) {
      return text.substring(0, maxLength) + '...';
    } else {
      return text;
    }
  }
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 10, right: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Color(0xFFF7F9FC),
        ),
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/images/sample.JPG'),//will change it soon
                        radius: 30,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: chatsDetails.status == 'online'
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chatsDetails.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                       Text(
                      truncateText(
                        chatsDetails.details,
                        20, // Set the desired number of words
                      ),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 100, top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                    chatsDetails.time,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                    Icon(
                      Icons.messenger,
                      size: 19,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
