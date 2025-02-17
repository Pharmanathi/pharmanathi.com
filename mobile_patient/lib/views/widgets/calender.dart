// ignore_for_file: avoid_print, unnecessary_string_interpolations, prefer_final_fields

import 'package:patient/config/color_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:patient/services/timeslot_api.dart';

class TableEventsExample extends StatefulWidget {
  final int doctorId;
  final Function(String) onAppointmentTimeSelected;
  final Function(DateTime) onAppointmentDaySelected;

  const TableEventsExample({
    Key? key,
    required this.doctorId,
    required this.onAppointmentTimeSelected,
    required this.onAppointmentDaySelected,
  }) : super(key: key);

  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  late final ValueNotifier<List<String>> _selectedTimeSlots;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late DateTime kFirstDay;
  late DateTime kLastDay;
  int _selectedButtonIndex = -1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final currentYear = DateTime.now().year;
    kFirstDay = DateTime(currentYear, 1, 1);
    kLastDay = DateTime(currentYear, 12, 31);
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _selectedTimeSlots = ValueNotifier([]);

    // Delay the initial call to _onDaySelected until after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onDaySelected(_selectedDay!, _focusedDay);
    });
  }

  @override
  void dispose() {
    _selectedTimeSlots.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailability(DateTime day) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final availability = await TimeSlotsApiService.fetchAvailabilitySlots(
        widget.doctorId,
        day,
        context,
      );

      final formattedAvailability =
          availability.map((slot) => '${slot[0]} - ${slot[1]}').toList();

      if (mounted) {
        _selectedTimeSlots.value = formattedAvailability;
      }
    } catch (e) {
      print('Error fetching availability: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _fetchAvailability(selectedDay);
      widget.onAppointmentDaySelected(selectedDay);
    } else {
      // Ensure parent callback is called even if the selected day is the same as the focused day
      _fetchAvailability(selectedDay);
      widget.onAppointmentDaySelected(selectedDay);
    }
  }

  void _onTimeSlotSelected(String selectedTimeSlot) {
    widget.onAppointmentTimeSelected(selectedTimeSlot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallet.PURE_WHITE,
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 5),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Pallet.PRAMARY_100,
                  width: 1.0.w,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: TableCalendar(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: true,
                  markerSize: 0,
                  defaultTextStyle: const TextStyle(fontSize: 16),
                  weekendTextStyle: const TextStyle(fontSize: 16),
                  todayDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Pallet.PRAMARY_75,
                    border: Border.all(
                      color: Pallet.PRIMARY_COLOR,
                      width: 1.0.w,
                    ),
                  ),
                  todayTextStyle: GoogleFonts.openSans(
                    color: Color.fromARGB(255, 26, 25, 25),
                    fontWeight: FontWeight.bold,
                  ),
                  selectedTextStyle: GoogleFonts.openSans(
                    color: Pallet.PRAMARY_75,
                    fontWeight: FontWeight.normal,
                  ),
                  selectedDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Pallet.PRIMARY_COLOR,
                    border: Border.all(
                      color: Pallet.PRAMARY_75,
                      width: 1.0,
                    ),
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedDay = focusedDay;
                  });

                  //* Call the parent callback with the updated focusedDay
                  widget.onAppointmentDaySelected(focusedDay);
                  _fetchAvailability(focusedDay);
                },
              ),
            ),
          ),
          SizedBox(height: 1.0.h),
          Padding(
            padding: EdgeInsets.only(left: 30, top: 20, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available Time',
                style: GoogleFonts.openSans(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _selectedTimeSlots,
              builder: (context, value, _) {
                if (_isLoading) {
                  // Show loading indicator while data is loading
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (value.isEmpty) {
                  // Show 'No time available' if there are no time slots
                  return Center(
                    child: Text(
                      'No time available',
                      style: GoogleFonts.openSans(fontSize: 16.sp),
                    ),
                  );
                } else {
                  // Show the time slots when available
                  List<String> sortedValues = List.from(value)
                    ..sort((a, b) =>
                        a.split(' - ')[0].compareTo(b.split(' - ')[0]));

                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 10.0.sp,
                      runSpacing: 8.0.sp,
                      children: List.generate(
                        sortedValues.length,
                        (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedButtonIndex = index;
                              print(
                                  'Selected time slot: ${sortedValues[index]}');
                            });
                            _onTimeSlotSelected(sortedValues[index]);
                          },
                          child: Container(
                            height: 45.h,
                            width: 120.w,
                            decoration: BoxDecoration(
                              color: _selectedButtonIndex == index
                                  ? Pallet.PRIMARY_COLOR
                                  : Pallet.PRAMARY_75,
                            ),
                            child: Center(
                              child: Text(
                                '${sortedValues[index].split(' - ')[0]}', //* Display only the start time
                                textAlign: TextAlign.center,
                                style: GoogleFonts.openSans(
                                  fontSize: 16.0.sp,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.normal,
                                  color: _selectedButtonIndex == index
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
