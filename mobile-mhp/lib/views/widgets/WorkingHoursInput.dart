import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_nathi/logging.dart';

import '../../services/working_hours_api.dart';

typedef MyBuilder = void Function(
    BuildContext context, void Function() getTimeslots);

class WorkingHoursInput extends StatefulWidget {
  final MyBuilder builder;
  final String day;
  final ValueChanged<List<String>> onTimeChanged;
  final List<String> days;

  const WorkingHoursInput({
    Key? key,
    required this.day,
    required this.onTimeChanged,
    required this.builder,
    required this.days,
  }) : super(key: key);

  @override
  _WorkingHoursInputState createState() => _WorkingHoursInputState();
}

class _WorkingHoursInputState extends State<WorkingHoursInput> {
  late SharedPreferences _prefs;
  List<TimeOfDay> startTimes = [TimeOfDay(hour: 0, minute: 0)];
  List<TimeOfDay> endTimes = [TimeOfDay(hour: 0, minute: 0)];
  bool isAvailable = false;
  final log = logger(WorkingHoursInput);

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _fetchAndSaveApiData();
    _loadSavedSettings();
  }

  Future<void> _fetchAndSaveApiData() async {
    final schedule = await WorkingHourApiService.fetchScheduleFromApi(context);

    schedule.forEach((day, timeslots) {
      final startTimes = timeslots.map((ts) => ts.split(',')[0]).toList();
      final endTimes = timeslots.map((ts) => ts.split(',')[1]).toList();

      _prefs.setStringList('${day}_startTimes', startTimes);
      _prefs.setStringList('${day}_endTimes', endTimes);
    });
  }

  void _loadSavedSettings() {
    setState(() {
      isAvailable = _prefs.getBool('${widget.day}_isAvailable') ?? false;
      _loadSavedTimes();
    });
  }

  void _saveSettings() {
    _prefs.setBool('${widget.day}_isAvailable', isAvailable);
  }

  void _saveTimes() {
    _prefs.setStringList(
      '${widget.day}_startTimes',
      startTimes.map((time) => '${time.hour}:${time.minute}').toList(),
    );
    _prefs.setStringList(
      '${widget.day}_endTimes',
      endTimes.map((time) => '${time.hour}:${time.minute}').toList(),
    );
  }

  void _loadSavedTimes() {
    final List<String>? savedStartTimes =
        _prefs.getStringList('${widget.day}_startTimes');
    final List<String>? savedEndTimes =
        _prefs.getStringList('${widget.day}_endTimes');

    if (savedStartTimes != null && savedEndTimes != null) {
      startTimes = savedStartTimes.map((time) {
        final List<int> parts = time.split(':').map(int.parse).toList();
        return TimeOfDay(hour: parts[0], minute: parts[1]);
      }).toList();

      endTimes = savedEndTimes.map((time) {
        final List<int> parts = time.split(':').map(int.parse).toList();
        return TimeOfDay(hour: parts[0], minute: parts[1]);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.builder.call(context, () => getTimeslots(widget.days));

    List<Widget> timeRows = [];

    for (int i = 0; i < startTimes.length; i++) {
      timeRows.add(
        Row(
          children: [
            _buildTimePicker('Start Time', startTimes[i],
                (TimeOfDay? selectedTime) {
              if (selectedTime != null) {
                setState(() {
                  startTimes[i] = selectedTime;
                  _saveTimes();
                  widget.onTimeChanged([
                    '${startTimes[i].hour}:${startTimes[i].minute}',
                    '${endTimes[i].hour}:${endTimes[i].minute}'
                  ]);
                });
              }
            }),
            SizedBox(width: 15),
            _buildTimePicker('End Time', endTimes[i],
                (TimeOfDay? selectedTime) {
              if (selectedTime != null) {
                setState(() {
                  endTimes[i] = selectedTime;
                  _saveTimes(); //* Save updated times
                  widget.onTimeChanged([
                    '${startTimes[i].hour}:${startTimes[i].minute}',
                    '${endTimes[i].hour}:${endTimes[i].minute}'
                  ]);
                });
              }
            }),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 7),
            Switch(
              value: isAvailable,
              onChanged: (value) {
                setState(() {
                  isAvailable = value;
                  if (!isAvailable) {
                    startTimes = [TimeOfDay(hour: 0, minute: 0)];
                    endTimes = [TimeOfDay(hour: 0, minute: 0)];
                  }
                  _saveSettings(); //* Save availability state
                  widget.onTimeChanged([
                    '${startTimes.first.hour}:${startTimes.first.minute}',
                    '${endTimes.first.hour}:${endTimes.first.minute}'
                  ]);
                });
              },
            ),
            Text(
              widget.day,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 15),
            if (isAvailable) ...[
              Column(
                children: timeRows,
              ),
              SizedBox(height: 10),
              //* Add more input button
              ElevatedButton(
                onPressed: _addTimeRow,
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(6),
                    elevation: 0,
                    backgroundColor: Colors.transparent),
                child: Icon(
                  Icons.add,
                  color: Colors.grey,
                  size: 12,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay selectedTime,
      ValueChanged<TimeOfDay?> onChanged) {
    return ElevatedButton(
      onPressed: () => _showTimePicker(selectedTime, onChanged),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        elevation: 0,
        backgroundColor: Colors.grey[100],
      ),
      child: Text(selectedTime.format(context)),
    );
  }

  Future<void> _showTimePicker(
      TimeOfDay selectedTime, ValueChanged<TimeOfDay?> onChanged) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    onChanged(pickedTime);
  }

  void _addTimeRow() {
    setState(() {
      startTimes.add(TimeOfDay(hour: 0, minute: 0));
      endTimes.add(TimeOfDay(hour: 0, minute: 0));
      _saveTimes();
    });
  }

  List<Map<String, String>> getTimeslots(List<String> days) {
    final List<Map<String, String>> allTimeslots = [];

    //* Generate timeslots for each available day
    for (String day in days) {
      if (widget.day == day && isAvailable) {
        for (int i = 0; i < startTimes.length; i++) {
          final Map<String, String> timeslot = {
            'day': day,
            'start_time': '${startTimes[i].hour}:${startTimes[i].minute}',
            'end_time': '${endTimes[i].hour}:${endTimes[i].minute}',
          };
          allTimeslots.add(timeslot);
        }
      }
    }
    return allTimeslots;
  }
}
