import 'dart:convert';

class User {
  int id;
  bool isDoctor;
  DoctorProfile? doctorProfile;
  DateTime? lastLogin;
  bool isActive;
  String firstName;
  String lastName;
  String email;
  int saIdNo;
  String initials;
  String title;
  String contactNo;
  String university;
  List<int> userPermissions;

  User({
    required this.id,
    required this.isDoctor,
    this.doctorProfile,
    this.lastLogin,
    required this.isActive,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.saIdNo,
    required this.initials,
    required this.title,
    required this.contactNo,
    required this.university,
    required this.userPermissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      isDoctor: json['is_doctor'],
      doctorProfile: json['doctor_profile'] ,
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      isActive: json['is_active'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      saIdNo: json['sa_id_no'],
      initials: json['initials'],
      title: json['title'],
      contactNo: json['contact_no'],
      university: json['university'],
      userPermissions: List<int>.from(json['user_permissions']),
    );
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


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'specialities': specialities.map((e) => e.toJson()).toList(),
      'hpcsa_no': hpcsaNo,
      'mp_no': mpNo,
      'practicelocations': practiceLocations,
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
