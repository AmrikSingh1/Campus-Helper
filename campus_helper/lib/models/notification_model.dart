import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  event, 
  assignment, 
  announcement, 
  grade, 
  reminder,
  system
}

class NotificationModel {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String userId;
  final NotificationType type;
  final String? relatedItemId;  // ID of the related event, assignment, etc.
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.userId,
    required this.type,
    this.relatedItemId,
    required this.isRead,
  });

  // Factory constructor to create a Notification from Firestore data
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Parse notification type from string
    NotificationType notificationType;
    try {
      notificationType = NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == (data['type'] ?? 'system'),
        orElse: () => NotificationType.system,
      );
    } catch (e) {
      notificationType = NotificationType.system;
    }

    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      type: notificationType,
      relatedItemId: data['relatedItemId'],
      isRead: data['isRead'] ?? false,
    );
  }

  // Convert Notification to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'type': type.toString().split('.').last,
      'relatedItemId': relatedItemId,
      'isRead': isRead,
    };
  }

  // Create a copy of this Notification with modified fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? timestamp,
    String? userId,
    NotificationType? type,
    String? relatedItemId,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      isRead: isRead ?? this.isRead,
    );
  }

  // Mark as read
  NotificationModel markAsRead() {
    return copyWith(isRead: true);
  }

  // Get icon for this notification type
  String getIconForType() {
    switch (type) {
      case NotificationType.event:
        return 'event';
      case NotificationType.assignment:
        return 'assignment';
      case NotificationType.announcement:
        return 'announcement';
      case NotificationType.grade:
        return 'grade';
      case NotificationType.reminder:
        return 'alarm';
      case NotificationType.system:
        return 'system_update';
    }
  }

  // Get color for this notification type
  int getColorForType() {
    switch (type) {
      case NotificationType.event:
        return 0xFF8C9EFF; // Light blue
      case NotificationType.assignment:
        return 0xFFFF9800; // Orange
      case NotificationType.announcement:
        return 0xFF4CAF50; // Green
      case NotificationType.grade:
        return 0xFFE91E63; // Pink
      case NotificationType.reminder:
        return 0xFFFFEB3B; // Yellow
      case NotificationType.system:
        return 0xFF9E9E9E; // Grey
    }
  }
} 