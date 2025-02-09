class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String category;
  bool isRead;  // Track read/unread state
  final String screen;
  final bool shouldNavigate;
  bool isExpanded;  // Track expanded/collapsed state

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.category,
    this.isRead = false,
    required this.screen,
    this.shouldNavigate = false,
    this.isExpanded = false,  // Default to false
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
      screen: json['screen'] as String,
      shouldNavigate: json['shouldNavigate'] == 1,
      isExpanded: json['isExpanded'] == 1,  // Convert from db value
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
      'screen': screen,
      'shouldNavigate': shouldNavigate ? 1 : 0,
      'isExpanded': isExpanded ? 1 : 0,  // Store in db as 1 (expanded) or 0 (collapsed)
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
    String? screen,
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
      screen: screen ?? this.screen,
      shouldNavigate: shouldNavigate ?? this.shouldNavigate,
      isExpanded: isExpanded ?? this.isExpanded, // Ensure isExpanded is updated
    );
  }
}
