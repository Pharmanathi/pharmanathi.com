import 'package:patient/model/appointment_type.dart';

class Doctor {
  final bool isVerified;
  final String imageURL;
  final String doctorFullName;
  final String doctorFirstName;
  final String doctorLastName;
  final List<AppointmentType> appointmentTypes;
  final List<String> specialities;
  final int id;
  final bool hasConsultedBefore;
  final List<PracticeLocation> practiceLocations;

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
    required this.practiceLocations,
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

    //* Extract practice locations and their addresses
    final practiceLocations = (json['practicelocations'] as List<dynamic>?)
            ?.map((location) => PracticeLocation.fromJson(location))
            .toList() ??
        [];

    return Doctor(
      doctorFullName: doctorFullName,
      doctorFirstName: doctorFirstName,
      doctorLastName: doctorLastName,
      isVerified: json['is_verified'],
      appointmentTypes: appointmentTypes,
      imageURL: json["user"]['image_url'] ?? '',
      specialities: specialities,
      id: json['id'],
      hasConsultedBefore: json['has_consulted_before'],
       practiceLocations: practiceLocations,
    );
  }

  //* Return the first appointment type if available
  AppointmentType? get appointmentType {
    return appointmentTypes.isNotEmpty ? appointmentTypes[0] : null;
  }

  //* Returns all specialty names
  String getAllSpecialityNames() {
    String joinedSpecialities = specialities.join('\n');
    // if (joinedSpecialities.length > 30) {
    //   return '${joinedSpecialities.substring(0, 30)}...';
    // } else {
    //   return joinedSpecialities;
    // }
    return specialities.length > 1
        ? "${specialities[0]} & more"
        : "${specialities[0]}";
  }
}

class Address {
  final int id;
  final String dateCreated;
  final String dateModified;
  final String line1;
  final String? line2; // Nullable
  final String suburb;
  final String city;
  final String province;
  final String? lat; // Nullable
  final String? long; // Nullable

  Address({
    required this.id,
    required this.dateCreated,
    required this.dateModified,
    required this.line1,
    this.line2,
    required this.suburb,
    required this.city,
    required this.province,
    this.lat,
    this.long,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      dateCreated: json['date_created'],
      dateModified: json['date_modified'],
      line1: json['line_1'],
      line2: json['line_2'],
      suburb: json['suburb'],
      city: json['city'],
      province: json['province'],
      lat: json['lat'],
      long: json['long'],
    );
  }
   //* Getter to return the full address as a formatted string
  String get fullAddress {
    final addressParts = [
      line1,
      line2,
      suburb,
      city,
      province,
    ];

    //* Remove null or empty parts and place in the next line
    return addressParts.where((part) => part != null && part.isNotEmpty).join('\n');
  }
}


class PracticeLocation {
  final int id;
  final String name;
  final Address address; 
  final String dateCreated;
  final String dateModified;

  PracticeLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.dateCreated,
    required this.dateModified,
  });

  factory PracticeLocation.fromJson(Map<String, dynamic> json) {
    return PracticeLocation(
      id: json['id'],
      name: json['name'],
      address: Address.fromJson(json['address']), 
      dateCreated: json['date_created'],
      dateModified: json['date_modified'],
    );
  }
}
