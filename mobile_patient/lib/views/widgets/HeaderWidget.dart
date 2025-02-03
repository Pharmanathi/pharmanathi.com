import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
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
      color: const Color(0xFF6F7ED7),
      child: SafeArea(
        bottom: false, // Prevents padding at the bottom
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 35.h),
          child: Row(
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: onBackTap ?? () => Navigator.pop(context),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              if (!showBackButton)
                SizedBox(width: 10.w), // Placeholder for back button space
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 21.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (showBackButton)
                SizedBox(width: 40.w), // Balances the back button width
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(120.h);
}
