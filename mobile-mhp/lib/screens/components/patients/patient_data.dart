class PatientData {
  final String name;
  final String details;
  final String imageUrl;
  final String status;

  PatientData({
    required this.name,
    required this.details,
    required this.imageUrl,
    required this.status,
  });

  factory PatientData.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'];
    return PatientData(
      name: '${patient['first_name']} ${patient['last_name']}',
      details: patient['details'] ?? '',
      imageUrl: patient['imageURL'] ?? '',
      status: patient['status'] ?? '',
    );
  }
}
