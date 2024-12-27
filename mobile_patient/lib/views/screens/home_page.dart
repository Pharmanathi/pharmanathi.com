import 'package:patient/Repository/appointment_repository.dart';
import 'package:patient/config/color_const.dart';
import 'package:patient/model/appointment_data.dart';
import 'package:patient/views/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/recent_appointments_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
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
      setState(() {
        appointmentData = fetchedAppointments;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading appointment data: $e');
      // Handle error as needed
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
      appBar: AppBar(
        backgroundColor: Pallet.PRIMARY_COLOR,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      backgroundColor: Pallet.BACKGROUND_COLOR,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 50, left: 25, right: 20, bottom: 10),
            child: Text(
              'Recently Visited',
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Builder(
                      builder: (context) {
                        final completedAppointments = appointmentData
                            .where((appointment) =>
                                appointment.status == "Completed")
                            .toList();

                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 0.1,
                            crossAxisSpacing: 10.0,
                            // childAspectRatio: 0.2 / 0.5, //* Aspect ratio of the tiles
                          ),
                          itemCount: completedAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = completedAppointments[index];
                            return RecentAppointmentsTile(
                              appointment: appointment,
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),

      // CustomBottomNavigationBar
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
