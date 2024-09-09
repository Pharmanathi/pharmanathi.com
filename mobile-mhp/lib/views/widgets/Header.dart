import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onBackTap;

  const HeaderWidget({
    Key? key,
    required this.text,
    this.onBackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 25, right: 30, left: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onBackTap ?? () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF6F7ED7),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 110, bottom: 2),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6F7ED7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
