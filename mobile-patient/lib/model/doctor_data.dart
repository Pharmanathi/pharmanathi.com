import 'package:client_pharmanathi/model/appointment_type.dart';

class Doctor {
  final bool isVerified;
  final String imageURL;
  final String doctorName;
  final AppointmentType appointmentType;
  final List<String> specialities;
  final int id;
  final bool hasConsultedBefore;

  Doctor({
    required this.isVerified,
    required this.imageURL,
    required this.doctorName,
    required this.appointmentType,
    required this.specialities,
    required this.id,
    required this.hasConsultedBefore,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final doctorFirstName = json['user']['first_name'] ?? '';
    final doctorLastName = json['user']['last_name'] ?? '';
    final doctorName = '$doctorFirstName $doctorLastName';

    // Handle appointmenttype mapping (assuming it's a Map)
    final appointmentType = AppointmentType.fromJson(json['appointment_type'] ?? {});

    return Doctor(
      doctorName: doctorName,
      isVerified: json['is_verified'] ?? false,
      appointmentType: appointmentType,
      imageURL: json['imageURL'] ?? '',
      specialities: List<String>.from(json['specialities'] ?? []),
      id: json['id'] ?? 0,
      hasConsultedBefore: json['has_consulted_before'] ?? false,
    );
  }

  //* Returns all specialty names, each on a new line
  String getAllSpecialityNames() {
    return specialities.join('\n');
  }
}
