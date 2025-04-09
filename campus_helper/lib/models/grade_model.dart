import 'package:cloud_firestore/cloud_firestore.dart';

class Grade {
  final String id;
  final String studentId;
  final String subjectId;
  final int semester;
  final int internalMarks;
  final int externalMarks;
  final int totalMarks;
  final String grade; // A+, A, B+, etc.
  final double gradePoints;
  final String academicYear;
  
  Grade({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.semester,
    required this.internalMarks,
    required this.externalMarks,
    required this.totalMarks,
    required this.grade,
    required this.gradePoints,
    required this.academicYear,
  });
  
  // Factory constructor to create a Grade from Firestore data
  factory Grade.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Grade(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      semester: data['semester'] ?? 1,
      internalMarks: data['internalMarks'] ?? 0,
      externalMarks: data['externalMarks'] ?? 0,
      totalMarks: data['totalMarks'] ?? 0,
      grade: data['grade'] ?? '',
      gradePoints: (data['gradePoints'] ?? 0.0).toDouble(),
      academicYear: data['academicYear'] ?? '',
    );
  }
  
  // Convert Grade to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'subjectId': subjectId,
      'semester': semester,
      'internalMarks': internalMarks,
      'externalMarks': externalMarks,
      'totalMarks': totalMarks,
      'grade': grade,
      'gradePoints': gradePoints,
      'academicYear': academicYear,
    };
  }
  
  // Calculate SGPA for multiple subjects in same semester
  static double calculateSGPA(List<Grade> semesterGrades) {
    if (semesterGrades.isEmpty) return 0.0;
    
    double totalPoints = 0.0;
    double totalCredits = 0.0;
    
    // This requires subjects to have credit information
    // In a real app, you would fetch subject credits from Firestore
    // For this example, we'll assume each subject has 4 credits
    const defaultCredits = 4.0;
    
    for (var grade in semesterGrades) {
      totalPoints += grade.gradePoints * defaultCredits;
      totalCredits += defaultCredits;
    }
    
    return totalPoints / totalCredits;
  }
  
  // Calculate CGPA across all semesters
  static double calculateCGPA(List<Grade> allGrades) {
    if (allGrades.isEmpty) return 0.0;
    
    // Group by semester
    Map<int, List<Grade>> gradeBySemester = {};
    for (var grade in allGrades) {
      if (!gradeBySemester.containsKey(grade.semester)) {
        gradeBySemester[grade.semester] = [];
      }
      gradeBySemester[grade.semester]!.add(grade);
    }
    
    // Calculate SGPA for each semester
    double totalSGPA = 0.0;
    int semesterCount = gradeBySemester.length;
    
    gradeBySemester.forEach((semester, grades) {
      totalSGPA += calculateSGPA(grades);
    });
    
    return totalSGPA / semesterCount;
  }
} 