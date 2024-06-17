// ignore_for_file: avoid_print, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:client_pharmanathi/services/timeslot_api.dart';

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
    try {
      final availability = await TimeSlotsApiService.fetchAvailabilitySlots(
        widget.doctorId,
        day,
        context,
      );

      print('Availability:');
      for (var slot in availability) {
        print('${slot[0]} - ${slot[1]}');
      }

      final formattedAvailability = availability
          .map((slot) => '${slot[0]} - ${slot[1]}')
          .toList();

      _selectedTimeSlots.value = formattedAvailability;
    } catch (e) {
      print('Error fetching availability: $e');
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
      body: Column(
        children: [
          TableCalendar(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: true,
              markerSize: 0,
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

              // Call the parent callback with the updated focusedDay
              widget.onAppointmentDaySelected(focusedDay);
              _fetchAvailability(focusedDay);
            },
          ),
          const SizedBox(height: 1.0),
          const Padding(
            padding: EdgeInsets.only(left: 50, top: 20, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available Time',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _selectedTimeSlots,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(
                    child: Text(
                      'No time available',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 8.0,
                      children: List.generate(
                        value.length,
                        (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedButtonIndex = index;
                              print('Selected time slot: ${value[index]}');
                            });
                            _onTimeSlotSelected(value[index]);
                          },
                          child: Container(
                            height: 35,
                            width: 120,
                            decoration: BoxDecoration(
                              color: _selectedButtonIndex == index
                                  ? Colors.blue
                                  : Colors.grey[300],
                            ),
                            child: Center(
                              child: Text(
                                '${value[index].split(' - ')[0]}', //* Display only the start time
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
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
