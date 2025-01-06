import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/config/color_const.dart';

class ClickableDay extends StatefulWidget {
  final String selectedMonth;
  final Map<int, int>
      appointmentsPerDay; // Map of day to number of appointments
  final void Function(int) onDaySelected; // Callback function

  const ClickableDay({
    required this.selectedMonth,
    required this.onDaySelected,
    required this.appointmentsPerDay,
  });

  @override
  _ClickableDayState createState() => _ClickableDayState();
}

class _ClickableDayState extends State<ClickableDay> {
  int selectedDay = -1; // To track the currently selected day
  final DateTime today = DateTime.now(); // Track current day
  late final ScrollController _scrollController; // Define ScrollController

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // Initialize it here

    // Wait for the widget to be built before scrolling to the current day
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDay();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose controller when not needed
    super.dispose();
  }

  // Function to scroll to the current day when the widget is built
  void _scrollToCurrentDay() {
    final monthMap = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };

    DateTime now = DateTime.now();
    DateTime monthDate = DateTime(now.year, monthMap[widget.selectedMonth]!, 1);

    // Calculate the position of the current day
    if (today.month == monthDate.month && today.year == monthDate.year) {
      final currentDayIndex = today.day - 1;
      // Scroll to the position of the current day (adjust with width of the card)
      _scrollController.animateTo(
        currentDayIndex * 50.0, // 45 width + some padding
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Map to convert month names to numeric values
    final monthMap = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };

    // Convert the selected month name to a DateTime object
    DateTime now = DateTime.now();
    DateTime monthDate = DateTime(now.year, monthMap[widget.selectedMonth]!, 1);

    return Container(
      height: 70, // Adjust the height as needed
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController, // Attach the ScrollController
        child: Row(
          children: List<Widget>.generate(
            DateTime(monthDate.year, monthDate.month + 1, 0).day,
            (index) {
              final day = index + 1;
              final dayOfWeek =
                  DateTime(monthDate.year, monthDate.month, day).weekday;

              // Get the number of appointments for this day
              final appointmentsForDay = widget.appointmentsPerDay[day] ?? 0;

              // Determine if this is the current day
              final isToday = today.year == monthDate.year &&
                  today.month == monthDate.month &&
                  today.day == day;

              // Determine if this day is selected
              final isClicked = selectedDay == day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDay = day;
                  });

                  // Call the callback function with the selected day
                  widget.onDaySelected(day);
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    // elevation: 0,
                    height: 55.h,
                    width: 45.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: isClicked
                          ? Pallet.PRIMARY_COLOR
                          : (isToday ? Pallet.PRIMARY_200 : Pallet.PRAMARY_80),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Day number at the top left
                          Text(
                            day.toString(),
                            style: GoogleFonts.openSans(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: isClicked || isToday
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Skeleton lines representing appointments
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(), // Disable scrolling
                              itemCount: appointmentsForDay,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Container(
                                      height: 2,
                                      width: double.infinity,
                                      color: isClicked || isToday
                                          ? Pallet.SECONDARY_500
                                          : Pallet.SECONDARY_500),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
