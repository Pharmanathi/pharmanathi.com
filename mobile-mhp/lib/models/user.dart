class User {
  int id;
  bool isDoctor;
  DoctorProfile? doctorProfile;
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
    this.doctorProfile,
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
          : null,
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      saIdNo: json['sa_id_no'], // Allow saIdNo to be nullable
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
      'doctor_profile': doctorProfile?.toJson(),
      'last_login': lastLogin?.toIso8601String(),
      'is_superuser': isSuperuser,
      'is_staff': isStaff,
      'is_active': isActive,
      'date_joined': dateJoined?.toIso8601String(),
      'date_created': dateCreated?.toIso8601String(),
      'date_modified': dateModified?.toIso8601String(),
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
  String mpNo;
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
      practiceLocations: json['practice_locations'] != null
          ? List<int>.from(json['practice_locations'])
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
