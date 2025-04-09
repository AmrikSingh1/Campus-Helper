import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  faculty,
  admin,
  guest
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final UserRole role;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isEmailVerified;
  final String? phoneNumber;
  final String? bio;
  final Map<String, dynamic>? academicInfo; // Major, year, etc.
  final List<String> enrolledCourses; // IDs of enrolled courses
  final List<String> projectIds; // IDs of projects user is part of
  final List<String> forumPostIds; // IDs of forum posts created by user
  final Map<String, dynamic>? preferences; // App preferences
  final Map<String, dynamic>? socialLinks; // Social media profiles
  final bool isActive;
  final String? fcmToken; // Firebase Cloud Messaging token for notifications

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.role,
    required this.createdAt,
    required this.lastLogin,
    required this.isEmailVerified,
    this.phoneNumber,
    this.bio,
    this.academicInfo,
    required this.enrolledCourses,
    required this.projectIds,
    required this.forumPostIds,
    this.preferences,
    this.socialLinks,
    required this.isActive,
    this.fcmToken,
  });

  // Factory constructor to create a UserModel from Firestore data
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Parse user role from string
    UserRole userRole;
    try {
      userRole = UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == (data['role'] ?? 'student'),
        orElse: () => UserRole.student,
      );
    } catch (e) {
      userRole = UserRole.student;
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      role: userRole,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isEmailVerified: data['isEmailVerified'] ?? false,
      phoneNumber: data['phoneNumber'],
      bio: data['bio'],
      academicInfo: data['academicInfo'] as Map<String, dynamic>?,
      enrolledCourses: List<String>.from(data['enrolledCourses'] ?? []),
      projectIds: List<String>.from(data['projectIds'] ?? []),
      forumPostIds: List<String>.from(data['forumPostIds'] ?? []),
      preferences: data['preferences'] as Map<String, dynamic>?,
      socialLinks: data['socialLinks'] as Map<String, dynamic>?,
      isActive: data['isActive'] ?? true,
      fcmToken: data['fcmToken'],
    );
  }

  // Create a new user model from Firebase auth data
  factory UserModel.fromFirebaseAuth(String uid, String email, String displayName, String? photoURL) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      role: UserRole.student, // Default role
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      isEmailVerified: false,
      enrolledCourses: [],
      projectIds: [],
      forumPostIds: [],
      isActive: true,
    );
  }

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'isEmailVerified': isEmailVerified,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'academicInfo': academicInfo,
      'enrolledCourses': enrolledCourses,
      'projectIds': projectIds,
      'forumPostIds': forumPostIds,
      'preferences': preferences,
      'socialLinks': socialLinks,
      'isActive': isActive,
      'fcmToken': fcmToken,
    };
  }

  // Create a copy of this UserModel with modified fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isEmailVerified,
    String? phoneNumber,
    String? bio,
    Map<String, dynamic>? academicInfo,
    List<String>? enrolledCourses,
    List<String>? projectIds,
    List<String>? forumPostIds,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? socialLinks,
    bool? isActive,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      academicInfo: academicInfo ?? this.academicInfo,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      projectIds: projectIds ?? this.projectIds,
      forumPostIds: forumPostIds ?? this.forumPostIds,
      preferences: preferences ?? this.preferences,
      socialLinks: socialLinks ?? this.socialLinks,
      isActive: isActive ?? this.isActive,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  // Get user role as a formatted string
  String getRoleString() {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.faculty:
        return 'Faculty';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.guest:
        return 'Guest';
      default:
        return 'Student';
    }
  }

  // Get user's academic year if available
  String? getAcademicYear() {
    if (academicInfo != null && academicInfo!.containsKey('year')) {
      return academicInfo!['year'].toString();
    }
    return null;
  }

  // Get user's major if available
  String? getMajor() {
    if (academicInfo != null && academicInfo!.containsKey('major')) {
      return academicInfo!['major'].toString();
    }
    return null;
  }

  // Get user's GPA if available
  double? getGPA() {
    if (academicInfo != null && academicInfo!.containsKey('gpa')) {
      return double.tryParse(academicInfo!['gpa'].toString());
    }
    return null;
  }

  // Check if user has admin privileges
  bool hasAdminPrivileges() {
    return role == UserRole.admin;
  }

  // Check if user has faculty privileges
  bool hasFacultyPrivileges() {
    return role == UserRole.faculty || role == UserRole.admin;
  }

  // Calculate account age in days
  int getAccountAge() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays;
  }

  // Get user initials for avatar
  String getInitials() {
    if (displayName.isEmpty) return '';
    
    List<String> nameParts = displayName.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }
    
    return '';
  }
} 