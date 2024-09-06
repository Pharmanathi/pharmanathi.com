import 'package:flutter/material.dart';
import 'package:pharma_nathi/logging.dart';

class WorkingHoursInput extends StatefulWidget {
  final String day;
  final ValueChanged<List<dynamic>> onTimeChanged;
  final List<dynamic>? daySchedule;

  const WorkingHoursInput({
    Key? key,
    required this.day,
    required this.onTimeChanged,
    required this.daySchedule,
  }) : super(key: key);

  @override
  _WorkingHoursInputState createState() => _WorkingHoursInputState();
}

class _WorkingHoursInputState extends State<WorkingHoursInput> {
  List<TimeOfDay> startTimes = [];
  List<TimeOfDay> endTimes = [];
  bool isAvailable = false;
  final log = logger(WorkingHoursInput);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _showTimePicker(
      TimeOfDay selectedTime, ValueChanged<TimeOfDay?> onChanged) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    onChanged(pickedTime);
  }

  Widget _buildTimePicker(String label, TimeOfDay selectedTime,
      ValueChanged<TimeOfDay?> onChanged) {
    return ElevatedButton(
      onPressed: () => _showTimePicker(selectedTime, onChanged),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        elevation: 0,
        backgroundColor: Colors.grey[100],
      ),
      child: Text(selectedTime.format(context)),
    );
  }

  void _addTimeRow() {
    setState(() {
      int nextHour = endTimes.last.hour;
      widget.onTimeChanged([
        widget.daySchedule!.length,
        TimeOfDay(hour: nextHour, minute: 0),
        TimeOfDay(hour: nextHour + 1, minute: 0)
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> timeRows = [];

    startTimes.clear();
    endTimes.clear();

    if (widget.daySchedule!.isNotEmpty) isAvailable = true;
    widget.daySchedule?.forEach((tod) {
      startTimes.add(tod[0]); // Return the first element from each sublist
      endTimes.add(tod[1]); // Return the first element from each sublist
    });

    for (int i = 0; i < startTimes.length; i++) {
      timeRows.add(
        Row(
          children: [
            _buildTimePicker('Start Time', startTimes[i],
                (TimeOfDay? selectedTime) {
              if (selectedTime != null) {
                setState(() {
                  startTimes[i] = selectedTime;
                  widget.onTimeChanged([
                    i, startTimes[i], endTimes[i]
                  ]);
                });
              }
            }),
            const SizedBox(width: 15),
            _buildTimePicker('End Time', endTimes[i],
                (TimeOfDay? selectedTime) {
              if (selectedTime != null) {
                setState(() {
                  endTimes[i] = selectedTime;
                  widget.onTimeChanged([
                    i, startTimes[i], endTimes[i]
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
            const SizedBox(width: 7),
            Switch(
              value: isAvailable,
              onChanged: (value) {
                setState(() {
                  if (!isAvailable) {
                    widget.onTimeChanged([
                      0, const TimeOfDay(hour: 9, minute: 0),
                      const TimeOfDay(hour: 10, minute: 0)
                    ]);
                  }
                  else{
                    widget.daySchedule!.clear();
                  }
                  isAvailable = !isAvailable;
                });
              },
            ),
            Text(
              widget.day,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 15),
            if (isAvailable) ...[
              Column(
                children: timeRows,
              ),
              const SizedBox(height: 10),
              //* Add more input button
              ElevatedButton(
                onPressed: _addTimeRow,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(6),
                    elevation: 0,
                    backgroundColor: Colors.transparent),
                child: const Icon(
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
}
