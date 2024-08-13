import 'package:client_pharmanathi/model/appointment_type.dart';

class Doctor {
  final bool isVerified;
  final String imageURL;
  final String doctorName;
  final List<AppointmentType> appointmentTypes;
  final List<String> specialities;
  final int id;
  final bool hasConsultedBefore;

  Doctor({
    required this.isVerified,
    required this.imageURL,
    required this.doctorName,
    required this.appointmentTypes,
    required this.specialities,
    required this.id,
    required this.hasConsultedBefore,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final doctorFirstName = json['user']['first_name'] ?? '';
    final doctorLastName = json['user']['last_name'] ?? '';
    final doctorName = '$doctorFirstName $doctorLastName';

    // Convert the list of appointment types to a list of AppointmentType objects
    final appointmentTypes = (json['appointment_types'] as List<dynamic>?)
            ?.map((item) => AppointmentType.fromJson(item))
            .toList() ??
        [];

    // Extracting specialities as a list of strings
    final specialities = (json['specialities'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        [];

    return Doctor(
      doctorName: doctorName,
      isVerified: json['is_verified'] ?? false,
      appointmentTypes: appointmentTypes,
      imageURL: json['imageURL'] ?? '',
      specialities: specialities,
      id: json['id'] ?? 0,
      hasConsultedBefore: json['has_consulted_before'] ?? false,
    );
  }

//* Returns all specialty names
//*Dear maintainer If you ever need more than 30 characters, you’re probably trying to write a novel. Keep it short and sweet!
  String getAllSpecialityNames() {
    String joinedSpecialities = specialities.join('\n');
    if (joinedSpecialities.length > 30) {
      return '${joinedSpecialities.substring(0, 30)}...';
    } else {
      return joinedSpecialities;
    }
  }
}
