import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String type; // 'exam', 'assignment', 'lecture', 'holiday', etc.
  final Color color;
  final String department;
  final int semester;
  final String subjectId;
  final bool isAllDay;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.type,
    required this.color,
    required this.department,
    required this.semester,
    required this.subjectId,
    required this.isAllDay,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Firestore document to CalendarEvent object
  factory CalendarEvent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Parse color from string
    Color eventColor = Colors.blue;
    if (data['color'] != null) {
      try {
        eventColor = Color(int.parse(data['color']));
      } catch (e) {
        // Default to blue if color parsing fails
        eventColor = Colors.blue;
      }
    }

    return CalendarEvent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      type: data['type'] ?? 'other',
      color: eventColor,
      department: data['department'] ?? '',
      semester: data['semester'] ?? 0,
      subjectId: data['subjectId'] ?? '',
      isAllDay: data['isAllDay'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as Timestamp).toDate() 
        : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
        ? (data['updatedAt'] as Timestamp).toDate() 
        : DateTime.now(),
    );
  }

  // Convert CalendarEvent object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'location': location,
      'type': type,
      'color': color.value.toString(),
      'department': department,
      'semester': semester,
      'subjectId': subjectId,
      'isAllDay': isAllDay,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // Create a copy of this CalendarEvent with modified fields
  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? type,
    Color? color,
    String? department,
    int? semester,
    String? subjectId,
    bool? isAllDay,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      type: type ?? this.type,
      color: color ?? this.color,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      subjectId: subjectId ?? this.subjectId,
      isAllDay: isAllDay ?? this.isAllDay,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to check if an event is happening now
  bool isHappeningNow() {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  // Helper method to get duration in minutes
  int getDurationInMinutes() {
    return endDate.difference(startDate).inMinutes;
  }

  // Helper method to format duration as a string
  String getFormattedDuration() {
    final duration = endDate.difference(startDate);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '$hours hr${hours > 1 ? 's' : ''} ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }
} 