import 'package:flutter/material.dart';

class ClickableDay extends StatefulWidget {
  final String selectedMonth;
  final void Function(int) onDaySelected; // Callback function

  const ClickableDay(
      {required this.selectedMonth, required this.onDaySelected});

  @override
  _ClickableDayState createState() => _ClickableDayState();
}

class _ClickableDayState extends State<ClickableDay> {
  int selectedDay = -1;

  @override
  Widget build(BuildContext context) {
    // Define a map to convert month names to numeric values
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
      height: 100, // Adjust the height as needed
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List<Widget>.generate(
            DateTime(monthDate.year, monthDate.month + 1, 0).day,
            (index) {
              final day = index + 1;
              final dayOfWeek =
                  DateTime(monthDate.year, monthDate.month, day).weekday;

              String dayName = "";
              switch (dayOfWeek) {
                case 1:
                  dayName = 'Mon';
                  break;
                case 2:
                  dayName = 'Tue';
                  break;
                case 3:
                  dayName = 'Wed';
                  break;
                case 4:
                  dayName = 'Thu';
                  break;
                case 5:
                  dayName = 'Fri';
                  break;
                case 6:
                  dayName = 'Sat';
                  break;
                case 7:
                  dayName = 'Sun';
                  break;
              }

              final isClicked = selectedDay == day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDay = day;
                  });

                  // Call the callback function with the selected day
                  widget.onDaySelected(day);
                },
                child: Column(
                  children: [
                    Container(
                      width: 50, // Width of the day container
                      height: 50, // Height of the day container
                      decoration: BoxDecoration(
                        color: isClicked
                            ? const Color.fromARGB(255, 188, 214, 239)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          day.toString(),
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: isClicked ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      dayName,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(
                      width:
                          65, // Adjust the width to control spacing between days
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
