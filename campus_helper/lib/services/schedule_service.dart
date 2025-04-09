import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_helper/models/schedule.dart';
import 'package:campus_helper/services/auth_service.dart';

class ScheduleService {
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Collection reference
  CollectionReference get _schedules => _firestore.collection('schedules');

  // Get user schedules (owned by current user)
  Stream<List<Schedule>> getUserSchedules() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _schedules
        .where('ownerId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList());
  }

  // Get schedules the user is participating in but doesn't own
  Stream<List<Schedule>> getParticipatingSchedules() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _schedules
        .where('participants', arrayContains: userId)
        .where('ownerId', isNotEqualTo: userId)
        .orderBy('ownerId')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList());
  }

  // Get public schedules that the user doesn't own or participate in
  Stream<List<Schedule>> getPublicSchedules() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _schedules
        .where('isPublic', isEqualTo: true)
        .where('ownerId', isNotEqualTo: userId)
        .where('participants', arrayContains: userId, isEqualTo: false)
        .orderBy('ownerId')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList());
  }

  // Create a new schedule
  Future<String> createSchedule(String title, String description, DateTime date, bool isPublic) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final docRef = await _schedules.add({
      'title': title,
      'description': description,
      'ownerId': user.uid,
      'ownerName': user.displayName ?? 'Anonymous',
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'isPublic': isPublic,
      'participants': [],
    });

    return docRef.id;
  }

  // Update an existing schedule
  Future<void> updateSchedule(Schedule schedule) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');
    if (schedule.ownerId != user.uid) throw Exception('Only the owner can update this schedule');

    await _schedules.doc(schedule.id).update(schedule.toMap());
  }

  // Delete a schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final doc = await _schedules.doc(scheduleId).get();
      final data = doc.data() as Map<String, dynamic>?;
      
      if (data == null) throw Exception('Schedule not found');
      if (data['ownerId'] != user.uid) throw Exception('Only the owner can delete this schedule');

      await _schedules.doc(scheduleId).delete();
      return true;
    } catch (e) {
      print('Error deleting schedule: $e');
      return false;
    }
  }

  // Join a schedule
  Future<void> joinSchedule(String scheduleId) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _schedules.doc(scheduleId).update({
      'participants': FieldValue.arrayUnion([user.uid]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Leave a schedule
  Future<void> leaveSchedule(String scheduleId) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _schedules.doc(scheduleId).update({
      'participants': FieldValue.arrayRemove([user.uid]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Get a specific schedule by ID
  Future<Schedule?> getScheduleById(String scheduleId) async {
    final doc = await _schedules.doc(scheduleId).get();
    if (!doc.exists) return null;
    return Schedule.fromFirestore(doc);
  }
} 