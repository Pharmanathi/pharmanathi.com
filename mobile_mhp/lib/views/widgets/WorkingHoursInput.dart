import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/config/color_const.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        elevation: 0,
        backgroundColor: Pallet.PURE_WHITE,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Add border radius
        ),
      ),
      child: SizedBox(
        width: 54.w,
        child: Text(
          selectedTime.format(context),
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            color: Pallet.Black, // Change text color here
            fontSize: 12, // Optional: adjust text size
          ),
        ),
      ),
    );
  }

  void _addTimeRow() {
    setState(() {
      int nextHour = endTimes.isNotEmpty ? endTimes.last.hour : 9;
      widget.onTimeChanged([
        widget.daySchedule!.length,
        TimeOfDay(hour: nextHour, minute: 0),
        TimeOfDay(hour: nextHour + 1, minute: 0)
      ]);
    });
  }

  void _removeTimeRow(int index) {
    setState(() {
      startTimes.removeAt(index);
      endTimes.removeAt(index);
      widget.daySchedule!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    startTimes.clear();
    endTimes.clear();
    
    if (widget.daySchedule != null && widget.daySchedule!.isNotEmpty) {
      isAvailable = true;
      widget.daySchedule!.forEach((tod) {
        if (tod != null &&
            tod.length >= 2 &&
            tod[0] != null &&
            tod[1] != null) {
          startTimes.add(tod[0] as TimeOfDay);
          endTimes.add(tod[1] as TimeOfDay);
        }
      });
    }

    List<Widget> timeRows = List.generate(
      startTimes.length,
      (i) => Row(
        children: [
          if (i > 0)
            SizedBox(
              width: 60.w,
            ),
          if (i >
              0) //* Only showing the remove button for rows after the first one
            IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Pallet.TRANSPARENT,
                  border: Border.all(
                    color: Pallet.Black,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.close,
                  color: Pallet.Black,
                  size: 6,
                ),
              ),
              onPressed: () => _removeTimeRow(i),
            ),
          _buildTimePicker('Start Time', startTimes[i],
              (TimeOfDay? selectedTime) {
            if (selectedTime != null) {
              setState(() {
                startTimes[i] = selectedTime;
                widget.onTimeChanged([i, startTimes[i], endTimes[i]]);
              });
            }
          }),
          const SizedBox(width: 15),
          _buildTimePicker('End Time', endTimes[i], (TimeOfDay? selectedTime) {
            if (selectedTime != null) {
              setState(() {
                endTimes[i] = selectedTime;
                widget.onTimeChanged([i, startTimes[i], endTimes[i]]);
              });
            }
          }),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.6, 
              child: Switch(
                activeColor: Pallet.PURE_WHITE,
                activeTrackColor: Pallet.PRIMARY_COLOR,
                inactiveTrackColor: Pallet.SECONDARY_500,
                inactiveThumbColor: Pallet.PURE_WHITE,
                value: isAvailable,
                onChanged: (value) {
                  setState(() {
                    if (!isAvailable) {
                      widget.onTimeChanged([
                        0,
                        const TimeOfDay(hour: 9, minute: 0),
                        const TimeOfDay(hour: 10, minute: 0)
                      ]);
                    } else {
                      widget.daySchedule!.clear();
                    }
                    isAvailable = !isAvailable;
                  });
                },
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 30.w,
              child: Text(
                widget.day,
                style:  GoogleFonts.openSans(
                  fontSize: 12,
                  color: Pallet.Black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 5),
            if (!isAvailable)
               Text(
                'Unavailable',
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  color: Pallet.SECONDARY_500,
                ),
              ),
            if (isAvailable && timeRows.isNotEmpty) timeRows[0],
            if (isAvailable)
              ElevatedButton(
                onPressed: _addTimeRow,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(2),
                    elevation: 0,
                    backgroundColor: Pallet.TRANSPARENT),
                child: const Icon(Icons.add, color: Pallet.Black, size: 12),
              ),
          ],
        ),
        if (isAvailable && timeRows.length > 1)
          Column(
            children: timeRows.sublist(1),
          ),
      ],
    );
  }
}
