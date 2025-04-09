import 'package:cloud_firestore/cloud_firestore.dart';

class Faculty {
  final String id;
  final String name;
  final String email;
  final String department;
  final String position; // Professor, Assistant Professor, etc.
  final String? imageUrl;
  final String? officeLocation;
  final String? officeHours;
  final String? phoneNumber;
  final List<String> subjects; // IDs of subjects taught
  
  Faculty({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    this.imageUrl,
    this.officeLocation,
    this.officeHours,
    this.phoneNumber,
    required this.subjects,
  });
  
  // Factory constructor to create a Faculty from Firestore data
  factory Faculty.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Faculty(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      position: data['position'] ?? '',
      imageUrl: data['imageUrl'],
      officeLocation: data['officeLocation'],
      officeHours: data['officeHours'],
      phoneNumber: data['phoneNumber'],
      subjects: List<String>.from(data['subjects'] ?? []),
    );
  }
  
  // Convert Faculty to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'department': department,
      'position': position,
      'imageUrl': imageUrl,
      'officeLocation': officeLocation,
      'officeHours': officeHours,
      'phoneNumber': phoneNumber,
      'subjects': subjects,
    };
  }
  
  // Get short name/title for displaying
  String getShortTitle() {
    return 'Prof. ${name.split(' ').first}';
  }
  
  // Get formal title
  String getFormalTitle() {
    switch (position.toLowerCase()) {
      case 'professor':
        return 'Prof. $name';
      case 'associate professor':
        return 'Assoc. Prof. $name';
      case 'assistant professor':
        return 'Asst. Prof. $name';
      case 'lecturer':
        return 'Lect. $name';
      default:
        return name;
    }
  }
} 