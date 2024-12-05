class Payment {
  String provider;
  int user;
  String status;

  Payment({
    required this.provider,
    required this.user,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      provider: json['provider'],
      user: json['user'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'user': user,
      'status': status,
    };
  }
}
