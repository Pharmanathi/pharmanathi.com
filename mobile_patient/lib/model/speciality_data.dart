class Speciality {
  final int id;
  final String name;

  Speciality({
    required this.id,
    required this.name,
  });

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