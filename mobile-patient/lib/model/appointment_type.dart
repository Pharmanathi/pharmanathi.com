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
      id: json['id'] ,
      dateCreated:
          DateTime.tryParse(json['date_created'] ?? '') ?? DateTime.now(),
      dateModified:
          DateTime.tryParse(json['date_modified'] ?? '') ?? DateTime.now(),
      duration: json['duration'] ?? 0,
      isOnline: json['is_online'] ?? false,
      cost: json['cost'] ?? '',
      noShowCost: json['no_show_cost'] ?? '',
      isRunForever: json['is_run_forever'] ?? false,
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      doctor: json['doctor'] ?? 0,
    );
  }
}
