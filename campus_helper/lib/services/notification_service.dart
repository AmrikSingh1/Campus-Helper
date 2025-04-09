import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import '../models/calendar_event_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionPath = 'notifications';

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Get all notifications for the current user
  Stream<List<NotificationModel>> getNotifications() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
    });
  }

  // Get unread notifications count
  Stream<int> getUnreadNotificationsCount() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection(_collectionPath)
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      return;
    }

    final batch = _firestore.batch();
    
    final unreadNotifications = await _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    
    for (var doc in unreadNotifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    
    await batch.commit();
  }

  // Create a new notification
  Future<String> addNotification(NotificationModel notification) async {
    DocumentReference docRef = await _firestore
        .collection(_collectionPath)
        .add(notification.toFirestore());
    return docRef.id;
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection(_collectionPath).doc(notificationId).delete();
  }

  // Create event reminder notification
  Future<String> createEventReminderNotification(CalendarEvent event, {int minutesBefore = 30}) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final reminder = NotificationModel(
      id: '', // Will be set by Firestore
      title: 'Upcoming: ${event.title}',
      content: 'You have ${event.type} in $minutesBefore minutes at ${event.location}.',
      timestamp: DateTime.now(),
      userId: userId,
      type: NotificationType.reminder,
      relatedItemId: event.id,
      isRead: false,
    );

    return await addNotification(reminder);
  }

  // Create a system notification
  Future<String> createSystemNotification(String title, String content) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final notification = NotificationModel(
      id: '', // Will be set by Firestore
      title: title,
      content: content,
      timestamp: DateTime.now(),
      userId: userId,
      type: NotificationType.system,
      isRead: false,
    );

    return await addNotification(notification);
  }

  // Create an assignment notification
  Future<String> createAssignmentNotification(String assignmentId, String title, String dueDate) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final notification = NotificationModel(
      id: '', // Will be set by Firestore
      title: 'New Assignment: $title',
      content: 'A new assignment has been posted. Due on $dueDate.',
      timestamp: DateTime.now(),
      userId: userId,
      type: NotificationType.assignment,
      relatedItemId: assignmentId,
      isRead: false,
    );

    return await addNotification(notification);
  }

  // Create a grade notification
  Future<String> createGradeNotification(String subjectId, String subjectName, String grade) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final notification = NotificationModel(
      id: '', // Will be set by Firestore
      title: 'New Grade Posted',
      content: 'Your grade for $subjectName has been posted: $grade.',
      timestamp: DateTime.now(),
      userId: userId,
      type: NotificationType.grade,
      relatedItemId: subjectId,
      isRead: false,
    );

    return await addNotification(notification);
  }

  // Schedule event reminder
  Future<void> scheduleEventReminder(CalendarEvent event) async {
    // This is a simplified version. In a real app, you would use something like
    // flutter_local_notifications with a scheduled notification

    // For now, we'll just create a notification in Firestore
    // This would typically be done by a cloud function in a real app
    
    // Calculate reminder time (30 minutes before event)
    final reminderTime = event.startDate.subtract(const Duration(minutes: 30));
    
    // If the event is in the future, create a reminder notification
    if (reminderTime.isAfter(DateTime.now())) {
      // In a real app, you would schedule this notification to appear at reminderTime
      await createEventReminderNotification(event);
    }
  }
} 