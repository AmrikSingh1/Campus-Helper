import 'package:cloud_firestore/cloud_firestore.dart';

class Submission {
  final String id;
  final String assignmentId;
  final String studentId;
  final DateTime submissionDate;
  final String fileURL; // Google Drive link
  final int? marks;
  final String? feedback;
  final String status; // 'submitted', 'graded', 'late'
  
  Submission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.submissionDate,
    required this.fileURL,
    this.marks,
    this.feedback,
    required this.status,
  });
  
  // Factory constructor to create a Submission from Firestore data
  factory Submission.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Submission(
      id: doc.id,
      assignmentId: data['assignmentId'] ?? '',
      studentId: data['studentId'] ?? '',
      submissionDate: (data['submissionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fileURL: data['fileURL'] ?? '',
      marks: data['marks'],
      feedback: data['feedback'],
      status: data['status'] ?? 'submitted',
    );
  }
  
  // Convert Submission to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'submissionDate': Timestamp.fromDate(submissionDate),
      'fileURL': fileURL,
      'marks': marks,
      'feedback': feedback,
      'status': status,
    };
  }
} 