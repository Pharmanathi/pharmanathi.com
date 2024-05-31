class DoctorDetail {
  final String name;
  final String title;
  final String imageUrl;
  final String status;
  final String distance;
  final String rating;
  final String location;
  final String experience;
  final int doctorId;
  final int appointmentType;

  DoctorDetail(
      {required this.name,
      required this.distance,
      required this.appointmentType,
      required this.location,
      required this.experience,
      required this.rating,
      required this.title,
      required this.doctorId,
      required this.imageUrl,
      required this.status});
}
