class User {
  int id;
  bool isDoctor;
  DoctorProfile doctorProfile; // Changed from nullable to non-nullable
  String firstName;
  String lastName;
  String email;
  int? saIdNo; // Make saIdNo nullable
  String? initials;
  String? title;
  String? contactNo;
  String? university;
  List<int> userPermissions;

  User({
    required this.id,
    required this.isDoctor,
    required this.doctorProfile, // Updated to be required
    required this.firstName,
    required this.lastName,
    required this.email,
    this.saIdNo,
    this.initials,
    this.title,
    this.contactNo,
    this.university,
    required this.userPermissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      isDoctor: json['is_doctor'],
      doctorProfile: json['doctor_profile'] != null
          ? DoctorProfile.fromJson(json['doctor_profile'])
          : DoctorProfile(
              id: 0,
              specialities: [],
              hpcsaNo: '',
              mpNo: '',
              practiceLocations: [],
            ), // Provide default values to ensure non-null
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      saIdNo: json['sa_id_no'],
      initials: json['initials'],
      title: json['title'],
      contactNo: json['contact_no'],
      university: json['university'],
      userPermissions: json['user_permissions'] != null
          ? List<int>.from(json['user_permissions'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_doctor': isDoctor,
      'doctor_profile': doctorProfile.toJson(),
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'sa_id_no': saIdNo,
      'initials': initials,
      'title': title,
      'contact_no': contactNo,
      'university': university,
      'user_permissions': userPermissions,
    };
  }
}

class DoctorProfile {
  int id;
  List<Speciality> specialities;
  String hpcsaNo;
  String? mpNo;
  List<int> practiceLocations;

  DoctorProfile({
    required this.id,
    required this.specialities,
    required this.hpcsaNo,
    required this.mpNo,
    required this.practiceLocations,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'],
      specialities: json['specialities'] != null
          ? (json['specialities'] as List)
              .map((specialityJson) => Speciality.fromJson(specialityJson))
              .toList()
          : [],
      hpcsaNo: json['hpcsa_no'],
      mpNo: json['mp_no'],
      practiceLocations: json['practicelocations'] != null
          ? List<int>.from(json['practicelocations'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'specialities': specialities.map((e) => e.toJson()).toList(),
      'hpcsa_no': hpcsaNo,
      'mp_no': mpNo,
      'practice_locations': practiceLocations,
    };
  }
}

class Speciality {
  int id;
  String name;

  Speciality({required this.id, required this.name});

  factory Speciality.fromJson(Map<String, dynamic> json) {
    return Speciality(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class PracticeLocation {
  int id;
  Address address;
  String dateCreated;
  String dateModified;
  String name;

  PracticeLocation({
    required this.id,
    required this.address,
    required this.dateCreated,
    required this.dateModified,
    required this.name,
  });

  factory PracticeLocation.fromJson(Map<String, dynamic> json) {
    return PracticeLocation(
      id: json['id'],
      address: Address.fromJson(json['address']),
      dateCreated: json['date_created'],
      dateModified: json['date_modified'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address.toJson(),
      'date_created': dateCreated,
      'date_modified': dateModified,
      'name': name,
    };
  }
}

class Address {
  int id;
  String dateCreated;
  String dateModified;
  String line1;
  String? line2;
  String suburb;
  String city;
  String province;

  Address({
    required this.id,
    required this.dateCreated,
    required this.dateModified,
    required this.line1,
    this.line2,
    required this.suburb,
    required this.city,
    required this.province,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int,
      dateCreated: json['date_created'],
      dateModified: json['date_modified'],
      line1: json['line_1'] as String,
      line2: json['line_2'] as String?, // Nullable
      suburb: json['suburb'] as String,
      city: json['city'] as String,
      province: json['province'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_created': dateCreated,
      'date_modified': dateModified,
      'line_1': line1,
      'line_2': line2,
      'suburb': suburb,
      'city': city,
      'province': province,
    };
  }
}
