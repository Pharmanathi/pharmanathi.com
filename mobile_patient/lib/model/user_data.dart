class User {
  final int id;
  final bool isDoctor;
  final dynamic doctorProfile;
  final String firstName;
  final String lastName;
  final String email;
  final dynamic saIdNo;
  final dynamic initials;
  final dynamic title;
  final dynamic contactNo;
  final dynamic university;

  User({
    required this.id,
    required this.isDoctor,
    required this.doctorProfile,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.saIdNo,
    required this.initials,
    required this.title,
    required this.contactNo,
    required this.university,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      isDoctor: json['is_doctor'],
      doctorProfile: json['doctor_profile'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      saIdNo: json['sa_id_no'],
      initials: json['initials'],
      title: json['title'],
      contactNo: json['contact_no'],
      university: json['university'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_doctor': isDoctor,
      'doctor_profile': doctorProfile,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'sa_id_no': saIdNo,
      'initials': initials,
      'title': title,
      'contact_no': contactNo,
      'university': university,
    };
  }
}
