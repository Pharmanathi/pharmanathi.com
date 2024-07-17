// ignore_for_file: use_super_parameters, prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:pharma_nathi/logging.dart';
import 'package:pharma_nathi/views/screens/profile.dart';
import '../../services/working_hours_api.dart';
import '../../views/widjets/WorkingHoursInput.dart';
import '../../views/widjets/buttons.dart';

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

  final Map<String, List> schedule = {
    "1": [],
    "2": [],
    "3": [],
    "4": [],
    "5": [],
    "6": [],
    "7": [],
  };

  @override
  void initState() {
    super.initState();
    //* Initialize the list with one WorkingHoursInput widget for each day
    dayInputs = days.map((day) => _buildWorkingHoursInput(day, days)).toList();

    //* Fetch schedule from API when the app starts
    _fetchScheduleFromApi();
  }

  //* Method to build WorkingHoursInput widget for a day
  Widget _buildWorkingHoursInput(String day, List<String> days) {
    return WorkingHoursInput(
      day: day,
      onTimeChanged: (List<String> value) {
        setState(() {
          final List timeslots = _updateWorkingHours.call();
          if (timeslots.isNotEmpty) {
            String dayString = timeslots[0]["day"];
            int dayInt = days.indexOf(dayString) + 1;
            schedule[dayInt.toString()] = timeslots
                .map((ts) => [ts["start_time"], ts["end_time"]])
                .toList();
          }
        });
        log.d(day);
        log.d(schedule);
      },
      builder: (BuildContext context, Function() getTimeslots) {
        //* Assign the function to _updateWorkingHours
        _updateWorkingHours = () => getTimeslots();
      },
      days: days, //* Pass the 'days' parameter here
    );
  }

  //* Method to add a new WorkingHoursInput widget
  void addDayInput() {
    setState(() {
      dayInputs.add(_buildWorkingHoursInput('New Day', days));
    });
  }

  Future<void> _fetchScheduleFromApi() async {
    //* Call the fetchScheduleFromApi method
    Map<String, List> fetchedSchedule =
        await WorkingHourApiService.fetchScheduleFromApi(context);

    setState(() {
      schedule.addAll(fetchedSchedule);
    });
    log.i(fetchedSchedule);
  }

  //* Method to send schedule to API
 void _sendScheduleToApi() {
  WorkingHourApiService.sendSchedule(schedule, context, onSuccess: () {
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
                Column(
                  children: dayInputs,
                ),
                SizedBox(height: 20),
                //* Buttons
                MyButtonWidgets(
                  buttonText1: 'SAVE',
                  onPressed1: _sendScheduleToApi,
                  buttonText2: 'Cancel',
                  onPressed2: () {
                    Navigator.pop(context);
                  },
                ).buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
