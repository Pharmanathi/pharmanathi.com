import 'package:client_pharmanathi/model/appointment_type.dart';
import 'package:client_pharmanathi/model/speciality_data.dart';

class Doctor {
  final bool isVerified;
  final String imageURL;
  final String doctorName;
  final List<String> specialities;
  final int id;
  final bool hasConsultedBefore;

  Doctor({
    required this.isVerified,
    required this.imageURL,
    required this.doctorName,
    required this.specialities,
    required this.id,
    required this.hasConsultedBefore,
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
      id: json['id'],
      hasConsultedBefore: json['has_consulted_before'],
    );
  }

  //* Returns all specialty names, each on a new line
  String getAllSpecialityNames() {
    return specialities.join('\n');
  }
}
