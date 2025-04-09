import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  final String id;
  final String name;
  final String code; // Course code e.g., CS101
  final String description;
  final int credits;
  final String? departmentId;
  final String? facultyId; // ID of the faculty member teaching this subject
  final String? facultyName; // Name of faculty for display purposes
  final String? semester; // Fall 2023, Spring 2024, etc.
  final List<String> prerequisites; // IDs of prerequisite courses
  final List<String> enrolledStudentIds; // IDs of enrolled students
  final String? syllabus; // URL to syllabus document or content
  final Map<String, dynamic>? schedule; // Class schedule information
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final Map<String, dynamic>? gradeDistribution; // Grade breakdown
  final List<Map<String, dynamic>>? assignments; // List of assignments
  final double? averageRating; // Average rating from student reviews
  final int? reviewCount; // Number of reviews

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.credits,
    this.departmentId,
    this.facultyId,
    this.facultyName,
    this.semester,
    required this.prerequisites,
    required this.enrolledStudentIds,
    this.syllabus,
    this.schedule,
    this.startDate,
    this.endDate,
    required this.isActive,
    this.gradeDistribution,
    this.assignments,
    this.averageRating,
    this.reviewCount,
  });

  // Factory constructor to create a Subject from Firestore data
  factory Subject.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Subject(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      credits: data['credits'] ?? 0,
      departmentId: data['departmentId'],
      facultyId: data['facultyId'],
      facultyName: data['facultyName'],
      semester: data['semester'],
      prerequisites: List<String>.from(data['prerequisites'] ?? []),
      enrolledStudentIds: List<String>.from(data['enrolledStudentIds'] ?? []),
      syllabus: data['syllabus'],
      schedule: data['schedule'] as Map<String, dynamic>?,
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
      gradeDistribution: data['gradeDistribution'] as Map<String, dynamic>?,
      assignments: data['assignments'] != null 
          ? List<Map<String, dynamic>>.from(data['assignments']) 
          : null,
      averageRating: (data['averageRating'] is int) 
          ? (data['averageRating'] as int).toDouble() 
          : data['averageRating'],
      reviewCount: data['reviewCount'],
    );
  }

  // Convert Subject to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'credits': credits,
      'departmentId': departmentId,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'semester': semester,
      'prerequisites': prerequisites,
      'enrolledStudentIds': enrolledStudentIds,
      'syllabus': syllabus,
      'schedule': schedule,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isActive': isActive,
      'gradeDistribution': gradeDistribution,
      'assignments': assignments,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
    };
  }

  // Create a copy of this Subject with modified fields
  Subject copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    int? credits,
    String? departmentId,
    String? facultyId,
    String? facultyName,
    String? semester,
    List<String>? prerequisites,
    List<String>? enrolledStudentIds,
    String? syllabus,
    Map<String, dynamic>? schedule,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    Map<String, dynamic>? gradeDistribution,
    List<Map<String, dynamic>>? assignments,
    double? averageRating,
    int? reviewCount,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      credits: credits ?? this.credits,
      departmentId: departmentId ?? this.departmentId,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      semester: semester ?? this.semester,
      prerequisites: prerequisites ?? this.prerequisites,
      enrolledStudentIds: enrolledStudentIds ?? this.enrolledStudentIds,
      syllabus: syllabus ?? this.syllabus,
      schedule: schedule ?? this.schedule,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      gradeDistribution: gradeDistribution ?? this.gradeDistribution,
      assignments: assignments ?? this.assignments,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  // Check if the course is currently in session
  bool isInSession() {
    if (startDate == null || endDate == null) return false;
    
    final now = DateTime.now();
    return now.isAfter(startDate!) && now.isBefore(endDate!);
  }

  // Get the duration of the course in weeks
  int getCourseDurationInWeeks() {
    if (startDate == null || endDate == null) return 0;
    
    final difference = endDate!.difference(startDate!);
    return (difference.inDays / 7).ceil();
  }

  // Get enrollment count
  int getEnrollmentCount() {
    return enrolledStudentIds.length;
  }

  // Check if a student is enrolled in this course
  bool isStudentEnrolled(String studentId) {
    return enrolledStudentIds.contains(studentId);
  }

  // Add a student to the enrolled list
  Subject enrollStudent(String studentId) {
    if (enrolledStudentIds.contains(studentId)) {
      return this;
    }
    
    List<String> updatedEnrolledStudentIds = List.from(enrolledStudentIds);
    updatedEnrolledStudentIds.add(studentId);
    
    return copyWith(enrolledStudentIds: updatedEnrolledStudentIds);
  }

  // Remove a student from the enrolled list
  Subject unenrollStudent(String studentId) {
    if (!enrolledStudentIds.contains(studentId)) {
      return this;
    }
    
    List<String> updatedEnrolledStudentIds = List.from(enrolledStudentIds);
    updatedEnrolledStudentIds.remove(studentId);
    
    return copyWith(enrolledStudentIds: updatedEnrolledStudentIds);
  }

  // Helper to get a formatted representation of the course schedule
  String? getFormattedSchedule() {
    if (schedule == null) return null;
    
    List<String> scheduleStrings = [];
    
    if (schedule!.containsKey('days') && schedule!.containsKey('startTime') && schedule!.containsKey('endTime')) {
      final days = schedule!['days'];
      final startTime = schedule!['startTime'];
      final endTime = schedule!['endTime'];
      
      if (days is List && startTime is String && endTime is String) {
        final daysStr = (days as List).join(', ');
        scheduleStrings.add('$daysStr from $startTime to $endTime');
      }
    }
    
    if (schedule!.containsKey('location')) {
      final location = schedule!['location'];
      if (location is String) {
        scheduleStrings.add('Location: $location');
      }
    }
    
    return scheduleStrings.isEmpty ? null : scheduleStrings.join(' - ');
  }

  // Function to update the average rating when a new review is added
  Subject updateRating(double newRating) {
    final currentReviewCount = reviewCount ?? 0;
    final currentAverageRating = averageRating ?? 0.0;
    
    // Calculate the new average rating
    final totalRatingPoints = currentAverageRating * currentReviewCount;
    final newTotalRatingPoints = totalRatingPoints + newRating;
    final newReviewCount = currentReviewCount + 1;
    final newAverageRating = newTotalRatingPoints / newReviewCount;
    
    return copyWith(
      averageRating: newAverageRating,
      reviewCount: newReviewCount,
    );
  }

  // Add a new assignment
  Subject addAssignment(Map<String, dynamic> assignment) {
    List<Map<String, dynamic>> updatedAssignments = 
        List<Map<String, dynamic>>.from(assignments ?? []);
    updatedAssignments.add(assignment);
    
    return copyWith(assignments: updatedAssignments);
  }
} 