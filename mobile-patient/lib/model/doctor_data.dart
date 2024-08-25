import 'package:client_pharmanathi/model/appointment_type.dart';

class Doctor {
  final bool isVerified;
  final String imageURL;
  final String doctorFullName;
  final String doctorFirstName;
    final String doctorLastName ;
  final List<AppointmentType> appointmentTypes;
  final List<String> specialities;
  final int id;
  final bool hasConsultedBefore;

  Doctor({
    required this.isVerified,
    required this.imageURL,
     required this.doctorFirstName,
       required this.doctorLastName,
    required this.doctorFullName,
    required this.appointmentTypes,
    required this.specialities,
    required this.id,
    required this.hasConsultedBefore,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final doctorFirstName = json['user']['first_name'];
    final doctorLastName = json['user']['last_name'];
    final doctorFullName = '$doctorFirstName $doctorLastName';

    //* Convert the list of appointment types to a list of AppointmentType objects
    final appointmentTypes = (json['appointment_types'] as List<dynamic>?)
            ?.map((item) => AppointmentType.fromJson(item))
            .toList() ??
        [];

    //* Extracting specialities as a list of strings
    final specialities = (json['specialities'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        [];

    return Doctor(
      doctorFullName: doctorFullName,
      doctorFirstName: doctorFirstName,
      doctorLastName:doctorLastName,
      isVerified: json['is_verified'],
      appointmentTypes: appointmentTypes,
      imageURL: json["user"]['image_url'] ?? '',
      specialities: specialities,
      id: json['id'],
      hasConsultedBefore: json['has_consulted_before'] ,
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
