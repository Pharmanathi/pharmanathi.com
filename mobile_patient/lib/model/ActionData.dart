class ActionData {
  final String paymentUrl;

  ActionData({required this.paymentUrl});

  factory ActionData.fromJson(Map<String, dynamic> json) {
    return ActionData(
      paymentUrl: json['action_data']['payment_url'],
    );
  }
}
