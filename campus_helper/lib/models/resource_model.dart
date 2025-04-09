import 'package:cloud_firestore/cloud_firestore.dart';

class Resource {
  final String id;
  final String title;
  final String type; // 'notes', 'paper', 'book', etc.
  final String subjectId;
  final String uploadedById;
  final String fileURL; // Google Drive link
  final DateTime uploadDate;
  final String description;
  final List<String> tags;
  
  Resource({
    required this.id,
    required this.title,
    required this.type,
    required this.subjectId,
    required this.uploadedById,
    required this.fileURL,
    required this.uploadDate,
    required this.description,
    required this.tags,
  });
  
  // Factory constructor to create a Resource from Firestore data
  factory Resource.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Resource(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      subjectId: data['subjectId'] ?? '',
      uploadedById: data['uploadedById'] ?? '',
      fileURL: data['fileURL'] ?? '',
      uploadDate: (data['uploadDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
  
  // Convert Resource to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'type': type,
      'subjectId': subjectId,
      'uploadedById': uploadedById,
      'fileURL': fileURL,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'description': description,
      'tags': tags,
    };
  }
} 