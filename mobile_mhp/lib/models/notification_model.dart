class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String category;
  bool isRead; 
  final bool shouldNavigate;
  bool isExpanded;  

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.category,
    this.isRead = false,
    this.shouldNavigate = false,
    this.isExpanded = false, 
  });

  // Convert from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      category: json['category'] as String,
      isRead: json['isRead'] == 1,
      shouldNavigate: json['shouldNavigate'] == 1,
      isExpanded: json['isExpanded'] == 1, 
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'isRead': isRead ? 1 : 0,
      'shouldNavigate': shouldNavigate ? 1 : 0,
      'isExpanded': isExpanded ? 1 : 0,  
    };
  }

  // Add a copyWith method
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    String? category,
    bool? isRead,
    bool? shouldNavigate,
    bool? isExpanded,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      shouldNavigate: shouldNavigate ?? this.shouldNavigate,
      isExpanded: isExpanded ?? this.isExpanded, 
    );
  }
}
