// TODO(nehemie): rename this module to "appointments"(plural)
import 'package:intl/intl.dart';
import 'package:patient/Repository/appointment_repository.dart';
import 'package:patient/model/appointment_data.dart';
import 'package:patient/views/widgets/navigation_bar.dart';
import 'package:patient/views/widgets/HeaderWidget.dart';
import 'package:patient/views/widgets/appointment_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class Appointments extends StatefulWidget {
  const Appointments({super.key});

  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  String selectedButton = 'Completed';
  Color primaryColor = const Color(0xFFF7F9FC);
  int _selectedIndex = 0;
  int selectedDay = -1;
  bool isLoading = true;
  late AppointmentRepository _appointmentRepository;
  List<Appointment> appointmentData = [];

  @override
  void initState() {
    super.initState();
    _appointmentRepository = context.read<AppointmentRepository>();
    _loadAppointmentData();
  }

  void _loadAppointmentData() async {
    try {
      List<Appointment> fetchedAppointments =
          await _appointmentRepository.fetchAppointments(context);

      //* Sort appointments first by year in descending order,
      //* then by date (month, day, year), and then by time (ascending)
      fetchedAppointments.sort((a, b) {
        DateTime dateA = DateFormat('dd MMM yyyy').parse(a.appointmentDate);
        DateTime dateB = DateFormat('dd MMM yyyy').parse(b.appointmentDate);

        //* Compare years in descending order
        if (dateA.year != dateB.year) {
          return dateB.year.compareTo(dateA.year);
        }

        //* If years are the same, compare by full date (month, day) in descending order
        int dateComparison =
            dateB.compareTo(dateA); //* Reversed comparison for descending order
        if (dateComparison != 0) {
          return dateComparison; //* If dates are different, return the comparison result
        }

        //* If the dates are the same, compare times (ascending order)
        DateTime timeA = DateFormat('hh:mm a').parse(a.appointmentTime);
        DateTime timeB = DateFormat('hh:mm a').parse(b.appointmentTime);

        return timeA.compareTo(timeB); //* Compare times in ascending order
      });

      setState(() {
        appointmentData = fetchedAppointments;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      //* Log the error and stack trace to Sentry
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );

      setState(() {
        isLoading = false;
      });

      //TODO:[Thabang] use a proper consistant error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load appointments. Please try again later.'),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(110.sp),
          child: const HeaderWidget(
            text: 'Appointments',
            showBackButton: false, //* Hide the back button if not needed
          )),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
        ),
        child: CustomScrollView(
          slivers: [
            isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : appointmentData.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/nodata.png',
                                width: 120.w,
                                height: 120.h,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No appointments available',
                                style: GoogleFonts.openSans(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final data = appointmentData[index];
                            return AppointmentListItem(appointment: data);
                          },
                          childCount: appointmentData.length,
                        ),
                      ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
