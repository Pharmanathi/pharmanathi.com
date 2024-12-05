class Patient {
  final String firstName;
  final String lastName;
  final String? contactNo;
  final String? initials;
  final String? title;
  final int id;

  Patient({
    required this.firstName,
    required this.lastName,
    this.contactNo,
    this.initials,
    this.title,
    required this.id,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      firstName: json['first_name'],
      lastName: json['last_name'],
      contactNo: json['contact_no'],
      initials: json['initials'],
      title: json['title'],
      id: json['id'],
    );
  }
}