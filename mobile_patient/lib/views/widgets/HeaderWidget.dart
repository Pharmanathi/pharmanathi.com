import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String text;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  const HeaderWidget({
    Key? key,
    required this.text,
    this.showBackButton = true,
    this.onBackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      color: const Color(0xFF6F7ED7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 75),
            child: Row(
              children: [
                if (showBackButton)
                  GestureDetector(
                    onTap: onBackTap ?? () {
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (!showBackButton)
                  const SizedBox(width: 10), // Placeholder for back button space

                const Spacer(), // Push text to center

                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(), // Push text to center

                if (showBackButton)
                  const SizedBox(width: 30), // Placeholder to balance the back button width
              ],
            ),
          ),
        ],
      ),
    );
  }
}
