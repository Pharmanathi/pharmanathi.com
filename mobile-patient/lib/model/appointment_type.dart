
class AppointmentType {
  final int id;
  final DateTime dateCreated;
  final DateTime dateModified;
  final int duration;
  final bool isOnline;
  final String cost;
  final String noShowCost;
  final bool isRunForever;
  final DateTime startDate;
  final DateTime endDate;
  final int doctor;

  AppointmentType({
    required this.id,
    required this.dateCreated,
    required this.dateModified,
    required this.duration,
    required this.isOnline,
    required this.cost,
    required this.noShowCost,
    required this.isRunForever,
    required this.startDate,
    required this.endDate,
    required this.doctor,
  });

  factory AppointmentType.fromJson(Map<String, dynamic> json) {
    return AppointmentType(
      id: json['id'],
      dateCreated: DateTime.parse(json['date_created']),
      dateModified: DateTime.parse(json['date_modified']),
      duration: json['duration'],
      isOnline: json['is_online'],
      cost: json['cost'],
      noShowCost: json['no_show_cost'],
      isRunForever: json['is_run_forever'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      doctor: json['doctor'],
    );
  }
}