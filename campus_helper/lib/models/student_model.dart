import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String userId; // Firebase Auth user ID
  final String name;
  final String email;
  final String rollNumber;
  final String department;
  final int semester;
  final String? imageUrl;
  final String? phoneNumber;
  final String? address;
  final DateTime joinDate;
  final double cgpa;
  final int attendancePercentage;
  final Map<String, dynamic> academicInfo; // Additional academic information
  
  Student({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.rollNumber,
    required this.department,
    required this.semester,
    this.imageUrl,
    this.phoneNumber,
    this.address,
    required this.joinDate,
    required this.cgpa,
    required this.attendancePercentage,
    required this.academicInfo,
  });
  
  // Factory constructor to create a Student from Firestore data
  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      department: data['department'] ?? '',
      semester: data['semester'] ?? 1,
      imageUrl: data['imageUrl'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      joinDate: (data['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cgpa: (data['cgpa'] ?? 0.0).toDouble(),
      attendancePercentage: data['attendancePercentage'] ?? 0,
      academicInfo: data['academicInfo'] ?? {},
    );
  }
  
  // Convert Student to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'rollNumber': rollNumber,
      'department': department,
      'semester': semester,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'address': address,
      'joinDate': Timestamp.fromDate(joinDate),
      'cgpa': cgpa,
      'attendancePercentage': attendancePercentage,
      'academicInfo': academicInfo,
    };
  }
  
  // Create a copy of this Student with modified fields
  Student copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? rollNumber,
    String? department,
    int? semester,
    String? imageUrl,
    String? phoneNumber,
    String? address,
    DateTime? joinDate,
    double? cgpa,
    int? attendancePercentage,
    Map<String, dynamic>? academicInfo,
  }) {
    return Student(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      rollNumber: rollNumber ?? this.rollNumber,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      imageUrl: imageUrl ?? this.imageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      joinDate: joinDate ?? this.joinDate,
      cgpa: cgpa ?? this.cgpa,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      academicInfo: academicInfo ?? this.academicInfo,
    );
  }
  
  // Get the formatted join date
  String getFormattedJoinDate() {
    return '${joinDate.day}/${joinDate.month}/${joinDate.year}';
  }
  
  // Get the academic year
  String getAcademicYear() {
    int yearsSinceJoining = DateTime.now().year - joinDate.year;
    if (DateTime.now().month < 7 && joinDate.month >= 7) {
      yearsSinceJoining--;
    }
    
    return 'Year ${yearsSinceJoining + 1}';
  }
  
  // Get attendance status
  String getAttendanceStatus() {
    if (attendancePercentage >= 90) {
      return 'Excellent';
    } else if (attendancePercentage >= 75) {
      return 'Good';
    } else if (attendancePercentage >= 60) {
      return 'Average';
    } else {
      return 'Poor';
    }
  }
  
  // Check if student is in final year
  bool isInFinalYear() {
    // Assuming 4 year course with 8 semesters
    return semester >= 7;
  }
} 