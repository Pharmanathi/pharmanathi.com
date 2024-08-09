import 'package:client_pharmanathi/model/appointment_type.dart';
import 'package:client_pharmanathi/model/speciality_data.dart';

class Doctor {
  final bool isVerified;
  final String imageURL;
  final String doctorName;
  final List<String> specialities;
  // final List<int> practiceLocations;
  final int id;
  final bool hasConsultedBefore;
  // final List<AppointmentType> appointmentTypes;

  Doctor({
    required this.isVerified,
    required this.imageURL,
    required this.doctorName,
    required this.specialities,
    // required this.practiceLocations,
    required this.id,
    required this.hasConsultedBefore,
    // required this.appointmentTypes,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final doctorFirstName = json['user']['first_name'] ?? '';
    final doctorLastName = json['user']['last_name'] ?? '';
    final doctorName = '$doctorFirstName $doctorLastName';

    return Doctor(
      doctorName: doctorName,
      isVerified: json['is_verified'],
      imageURL: json['imageURL'] ?? '',
      specialities: json['specialities'].cast<String>(),
      // practiceLocations: List<int>.from(json['practicelocations']),
      id: json['id'],
      hasConsultedBefore: json['has_consulted_before'],
      // appointmentTypes: (json['appointment_types'] as List<dynamic>)
      //     .map((e) => AppointmentType.fromJson(e))
      //     .toList(),
    );
  }

  //* Returns all specialty names, each on a new line
  String getAllSpecialityNames() {
    return specialities.join('\n');
  }
}
