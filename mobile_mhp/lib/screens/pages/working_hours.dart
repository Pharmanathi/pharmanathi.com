// ignore_for_file: use_super_parameters, prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/logging.dart';
import 'package:pharma_nathi/views/widgets/shared/showErrorSnackBar.dart';
import 'package:pharma_nathi/views/widgets/shared/success_snackbar.dart';
import '../../services/working_hours_api.dart';
import '../../views/widgets/WorkingHoursInput.dart';
import '../../views/widgets/buttons.dart';

class WorkingHours extends StatefulWidget {
  const WorkingHours({Key? key}) : super(key: key);

  @override
  _WorkingHoursState createState() => _WorkingHoursState();
}

class _WorkingHoursState extends State<WorkingHours> {
  late List<Widget> dayInputs;
  final log = logger(WorkingHours);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> weeklySchedule = [
    {"dayStr": "Mon", "schedule": <List<TimeOfDay>>[]},
    {"dayStr": "Tue", "schedule": <List<TimeOfDay>>[]},
    {"dayStr": "Wed", "schedule": <List<TimeOfDay>>[]},
    {"dayStr": "Thu", "schedule": <List<TimeOfDay>>[]},
    {"dayStr": "Fri", "schedule": <List<TimeOfDay>>[]},
    {"dayStr": "Sat", "schedule": <List<TimeOfDay>>[]},
    {"dayStr": "Sun", "schedule": <List<TimeOfDay>>[]}
  ];

  @override
  void initState() {
    super.initState();
    _fetchScheduleFromApi();
  }

  /// Compare ToDs so that we display a sorted schedule
  int compareSlots(List<TimeOfDay> slot1, List<TimeOfDay> slot2) {
    if (slot1.isEmpty || slot2.isEmpty) {
      return 0;
    }

    var totalMinutes1 = slot1[0].hour * 60 + slot1[0].minute;
    var totalMinutes2 = slot2[0].hour * 60 + slot2[0].minute;
    return totalMinutes1.compareTo(totalMinutes2);
  }

  // Method to build WorkingHoursInput widget for a day
  Widget _buildWorkingHoursInput(int weekDayIndex, Map weekDay) {
    weekDay["schedule"].sort(compareSlots);

    return WorkingHoursInput(
      day: weekDay['dayStr'],
      onTimeChanged: (List<dynamic> value) {
        setState(() {
          if (weeklySchedule[weekDayIndex]['schedule'].length <= value[0]) {
            weeklySchedule[weekDayIndex]['schedule'].add(<TimeOfDay>[]);
          }

          if (value[1] is TimeOfDay && value[2] is TimeOfDay) {
            weeklySchedule[weekDayIndex]['schedule']
                [value[0]] = <TimeOfDay>[value[1], value[2]];
          } else {
            weeklySchedule[weekDayIndex]['schedule'][value[0]] = <TimeOfDay>[];
          }
        });
      },
      daySchedule: weekDay["schedule"],
    );
  }

  Future<void> _fetchScheduleFromApi() async {
    Map<String, List> fetchedSchedule =
        await WorkingHourApiService.fetchScheduleFromApi(context);

    TimeOfDay buildTOD(String timeString) {
      List<int> parts = timeString.split(':').map(int.parse).toList();
      return TimeOfDay(hour: parts[0], minute: parts[1]);
    }

    setState(() {
      fetchedSchedule.forEach((index, schdl) {
        weeklySchedule[int.parse(index) - 1]["schedule"].clear();
        for (int i = 0; i < schdl.length; i++) {
          var [start, end] = schdl[i].split(',');
          weeklySchedule[int.parse(index) - 1]["schedule"]
              .add([buildTOD(start), buildTOD(end)]);
        }
      });
    });
  }

  //* Method to send schedule to API
  void _sendScheduleToApi() {
    List<Map> convertedRealSchedule = [];

    //* Process the schedule
    for (int i = 0; i < weeklySchedule.length; i++) {
      var schedule = weeklySchedule[i]["schedule"];

      //*This extra checks are present to handle edge cases that might arise when processing the schedule.They might seem redundant,but their purpose is to ensure the code is robust and avoids runtime errors.
      if (schedule != null && schedule.isNotEmpty) {
        schedule.forEach((slot) {
          if (slot != null && slot.length >= 2) {
            convertedRealSchedule.add({
              "day": i + 1,
              "start_time": "${slot[0].hour}:${slot[0].minute}",
              "end_time": "${slot[1].hour}:${slot[1].minute}",
            });
          }
        });
      }
    }

    //* Always call the API, even if the converted schedule is empty
    WorkingHourApiService.sendSchedule(
      convertedRealSchedule,
      context,
      onSuccess: () {
        showSuccessSnackBar(
            context, "Your schedule has been saved successfully!");
        _navigateToProfilePage();
      },
    );

    if (convertedRealSchedule.isEmpty) {
      showSuccessSnackBar(
          context, "Your schedule has been cleared successfully!");
      return;
    }
  }

  // Method to navigate to the profile page
  void _navigateToProfilePage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    dayInputs = <Widget>[];
    weeklySchedule.asMap().forEach((index, weekday) {
      dayInputs.add(_buildWorkingHoursInput(index, weekday));
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25, left: 25),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Color(0xFF6F7ED7),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Working Hours',
                        style: GoogleFonts.openSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 22),
                      Text(
                        'Your information will be shared with our Medical Expert team who will verify your identity',
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          color: Pallet.SECONDARY_500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    children: dayInputs,
                  ),
                ),
                SizedBox(height: 20),
                MyButtonWidgets(
                  buttonTextPrimary: 'SAVE',
                  onPressedPrimary: _sendScheduleToApi,
                  buttonTextSecondary: 'Cancel',
                  onPressedSecondary: () {
                    Navigator.pop(context);
                  },
                ).buildButtons(primaryFirst: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
