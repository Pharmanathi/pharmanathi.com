// ignore_for_file: use_super_parameters, prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:pharma_nathi/logging.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // GlobalKey for the Scaffold

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
  /// credit: https://stackoverflow.com/a/74023447/5253580
  int compareSlots(List<TimeOfDay> slot1, List<TimeOfDay> slot2) {
    var totalMinutes1 = slot1[0].hour * 60 + slot1[0].minute;
    var totalMinutes2 = slot2[0].hour * 60 + slot2[0].minute;
    return totalMinutes1.compareTo(totalMinutes2);
  }

  //* Method to build WorkingHoursInput widget for a day
  Widget _buildWorkingHoursInput(int weekDayIndex, Map weekDay) {
    weekDay["schedule"].sort(compareSlots);
    return WorkingHoursInput(
      day: weekDay['dayStr'],
      onTimeChanged: (List<dynamic> value) {
        setState(() {
          if(weeklySchedule[weekDayIndex]['schedule'].length <= value[0]) weeklySchedule[weekDayIndex]['schedule'].add(<TimeOfDay>[]);
            weeklySchedule[weekDayIndex]['schedule'][value[0]] = <TimeOfDay>[value[1], value[2]];
        });
      },
      daySchedule: weekDay["schedule"],
    );
  }

  Future<void> _fetchScheduleFromApi() async {
    //* Call the fetchScheduleFromApi method
    Map<String, List> fetchedSchedule =
        await WorkingHourApiService.fetchScheduleFromApi(context);

    
    TimeOfDay buildTOD(String timeString){
        List<int> parts = timeString.split(':').map(int.parse).toList();
        return TimeOfDay(hour: parts[0], minute: parts[1]);
      }

    setState(() {
      fetchedSchedule.forEach((index, schdl){
        weeklySchedule[int.parse(index) - 1]["schedule"].clear();
        for(int i=0;  i < schdl.length; i++){ 
        var [start, end] = schdl[i].split(',');
          weeklySchedule[int.parse(index) - 1]["schedule"].add([buildTOD(start), buildTOD(end)]);
        }
      });
    });
  }

  //* Method to send schedule to API
  void _sendScheduleToApi() {
    List<Map> convertedRealSchedule = [];
    for(int i = 0; i < weeklySchedule.length; i++ ){
      weeklySchedule[i]["schedule"].forEach((slot){
          convertedRealSchedule.add({
            "day": i+1, 
            "start_time": "${slot[0].hour}:${slot[0].minute}",
            "end_time": "${slot[1].hour}:${slot[1].minute}",
            });
      });
    }

    WorkingHourApiService.sendSchedule(convertedRealSchedule, context, onSuccess: () {
      _showSuccessMessage();
      _navigateToProfilePage();
    });
  }

  //* Method to show a success message using a SnackBar
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Schedule saved successfully!'),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  //* Method to navigate to the profile page
  void _navigateToProfilePage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    //* Initialize the list with one WorkingHoursInput widget for each day
    dayInputs = <Widget>[];
    weeklySchedule.asMap().forEach((index, weekday) {
      dayInputs.add(_buildWorkingHoursInput(index, weekday));
    });

    return Scaffold(
      key: _scaffoldKey, //* Assign the GlobalKey to the Scaffold
      backgroundColor: Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //* Top heading with back button
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
                //* Title and description
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Working Hours',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 22),
                      Text(
                        'Your information will be shared with our Medical Expert team who will verify your identity',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                //* Render WorkingHoursInput widgets dynamically
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    children: dayInputs,
                  ),
                ),
                SizedBox(height: 20),
                //* Buttons
                MyButtonWidgets(
                  buttonTextPrimary: 'SAVE',
                  onPressedPrimary: _sendScheduleToApi,
                  buttonTextSecondary: 'Cancel',
                  onPressedSecondary: () {
                    Navigator.pop(context);
                  },
                ).buildButtons(primaryFirst: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
