import 'package:patient/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
      width: double.infinity.sp,
      height: 120.h,
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
                    onTap: onBackTap ??
                        () {
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
                  SizedBox(width: 10.h), // Placeholder for back button space
                const Spacer(),
                Text(
                  text,
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 21.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                if (showBackButton)
                  SizedBox(
                      width: 30
                          .w), //* Placeholder to balance the back button width
              ],
            ),
          ),
        ],
      ),
    );
  }
}
