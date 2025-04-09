import 'package:cloud_firestore/cloud_firestore.dart';

class Assignment {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final DateTime dueDate;
  final int totalMarks;
  final String createdById;
  final String? fileURL; // Google Drive link (optional)
  final DateTime createdAt;
  final String status; // 'active', 'expired'
  
  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.dueDate,
    required this.totalMarks,
    required this.createdById,
    this.fileURL,
    required this.createdAt,
    required this.status,
  });
  
  // Factory constructor to create an Assignment from Firestore data
  factory Assignment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Assignment(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subjectId: data['subjectId'] ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalMarks: data['totalMarks'] ?? 0,
      createdById: data['createdById'] ?? '',
      fileURL: data['fileURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'active',
    );
  }
  
  // Convert Assignment to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'dueDate': Timestamp.fromDate(dueDate),
      'totalMarks': totalMarks,
      'createdById': createdById,
      'fileURL': fileURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }
  
  // Check if assignment is overdue
  bool isOverdue() {
    return DateTime.now().isAfter(dueDate);
  }
} 