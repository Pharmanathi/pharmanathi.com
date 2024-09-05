// ignore_for_file: use_super_parameters, prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:pharma_nathi/logging.dart';
import 'package:pharma_nathi/views/screens/profile.dart';
import '../../services/working_hours_api.dart';
import '../../views/widgets/WorkingHoursInput.dart';
import '../../views/widgets/buttons.dart';

class WorkingHours extends StatefulWidget {
  const WorkingHours({Key? key}) : super(key: key);

  @override
  _WorkingHoursState createState() => _WorkingHoursState();
}

class _WorkingHoursState extends State<WorkingHours> {
  late List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  late List<Widget> dayInputs;
  late List Function() _updateWorkingHours;
  final log = logger(WorkingHours);
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // GlobalKey for the Scaffold

  Map<String, List> schedule = {
    "1": [],
    "2": [],
    "3": [],
    "4": [],
    "5": [],
    "6": [],
    "7": [],
  };

List<Map<String, dynamic>> realSchedule = [
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
    // (() async =>{
    // //* Fetch schedule from API when the app starts
    // await _fetchScheduleFromApi()
    // this._buildWorkingHoursInput(day, days)
    // })();
    _fetchScheduleFromApi();
    // //* Initialize the list with one WorkingHoursInput widget for each day
    // dayInputs = days.map((day) => _buildWorkingHoursInput(day, days)).toList();
  }

  //* Method to build WorkingHoursInput widget for a day
  // Widget _buildWorkingHoursInput(String day, List<String> days) {
  Widget _buildWorkingHoursInput(int weekDayIndex, Map weekDay) {
    return WorkingHoursInput(
      day: weekDay['dayStr'],
      onTimeChanged: (List<dynamic> value) {
        log.i("Fucing value $value");
        setState(() {
          // final List timeslots = _updateWorkingHours.call();
          // if (timeslots.isNotEmpty) {
          //   // String dayString = timeslots[0]["day"];
          //   // int dayInt = weekDayIndex;
          //   // schedule[weekDayIndex.toString()] = timeslots
          //   //     .map((ts) => [ts["start_time"], ts["end_time"]])
          //   //     .toList();
          // if(realSchedule[weekDayIndex]['schedule'].isEmpty) realSchedule[weekDayIndex]['schedule'] = <TimeOfDay>[];
          if(realSchedule[weekDayIndex]['schedule'].length <= value[0]) realSchedule[weekDayIndex]['schedule'].add(<TimeOfDay>[]);
            realSchedule[weekDayIndex]['schedule'][value[0]] = <TimeOfDay>[value[1], value[2]];
          //   print("$timeslots Fuuuuuck --> $weekDayIndex ${realSchedule[weekDayIndex]['schedule']}");
          // }
        });
        log.d("Got -->>  $weekDayIndex $weekDay");
        log.d(" Fake schedule $schedule");
        log.d("Real Schedule $realSchedule");
        log.i("Hello");
      },
      builder: (BuildContext context, Function() getTimeslots) {
        //* Assign the function to _updateWorkingHours
        _updateWorkingHours = () => getTimeslots();
      },
      days: days, //* Pass the 'days' parameter here
      daySchedule: weekDay["schedule"],
      // onNewSlot: (){
      //   // Add a newly added slot to the schedule
      // },
    );
  }

  //* Method to add a new WorkingHoursInput widget
  // void addDayInput() {
  //   setState(() {
  //     dayInputs.add(_buildWorkingHoursInput(0, days));
  //   });
  // }

  Future<void> _fetchScheduleFromApi() async {
    //* Call the fetchScheduleFromApi method
    Map<String, List> fetchedSchedule =
        await WorkingHourApiService.fetchScheduleFromApi(context);

    
    TimeOfDay buildTOD(String timeString){
        List<int> parts = timeString.split(':').map(int.parse).toList();
        return TimeOfDay(hour: parts[0], minute: parts[1]);
      }


    log.i('Sechdule was $schedule, updating it to $fetchedSchedule');
    setState(() {
      // schedule.addAll(fetchedSchedule);
      fetchedSchedule.forEach((index, schdl){
        realSchedule[int.parse(index) - 1]["schedule"].clear();
        for(int i=0;  i < schdl.length; i++){ 
        var [start, end] = schdl[i].split(',');
          realSchedule[int.parse(index) - 1]["schedule"].add([buildTOD(start), buildTOD(end)]);
        }
        
      });
    });
  }

  //* Method to send schedule to API
  void _sendScheduleToApi() {
    log.i("to convert >>>>> $realSchedule");
    List<Map> convertedRealSchedule = [];
    for(int i = 0; i < realSchedule.length; i++ ){
      realSchedule[i]["schedule"].forEach((slot){
        // daySlots.forEach((slot){
          convertedRealSchedule.add({
            "day": i+1, 
            "start_time": "${slot[0].hour}:${slot[0].minute}",
            "end_time": "${slot[1].hour}:${slot[1].minute}",
            });
      // });
      });
    }

    log.i("Schedule being sent here >>>>> $convertedRealSchedule");
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
    // dayInputs = days.map((weekday) => _buildWorkingHoursInput(weekday)).toList();
    realSchedule.asMap().forEach((index, weekday) {
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
                  padding: const EdgeInsets.only(left: 25),
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
