import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/calendar_event_model.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'calendar_events';

  factory CalendarService() {
    return _instance;
  }

  CalendarService._internal();

  // Get all calendar events
  Stream<List<CalendarEvent>> getCalendarEvents() {
    return _firestore
        .collection(_collectionPath)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
    });
  }

  // Get calendar events by department
  Stream<List<CalendarEvent>> getCalendarEventsByDepartment(String department) {
    return _firestore
        .collection(_collectionPath)
        .where('department', isEqualTo: department)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
    });
  }

  // Get calendar events by semester
  Stream<List<CalendarEvent>> getCalendarEventsBySemester(int semester) {
    return _firestore
        .collection(_collectionPath)
        .where('semester', isEqualTo: semester)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
    });
  }

  // Get calendar events by type (exam, holiday, etc.)
  Stream<List<CalendarEvent>> getCalendarEventsByType(String type) {
    return _firestore
        .collection(_collectionPath)
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
    });
  }

  // Get calendar events for a specific date range
  Stream<List<CalendarEvent>> getCalendarEventsForDateRange(DateTime start, DateTime end) {
    return _firestore
        .collection(_collectionPath)
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
    });
  }

  // Add a calendar event
  Future<String> addCalendarEvent(CalendarEvent event) async {
    DocumentReference docRef = await _firestore.collection(_collectionPath).add(event.toFirestore());
    return docRef.id;
  }

  // Update a calendar event
  Future<void> updateCalendarEvent(CalendarEvent event) async {
    return await _firestore.collection(_collectionPath).doc(event.id).update(event.toFirestore());
  }

  // Delete a calendar event
  Future<void> deleteCalendarEvent(String eventId) async {
    return await _firestore.collection(_collectionPath).doc(eventId).delete();
  }

  // Get events by subject ID
  Stream<List<CalendarEvent>> getCalendarEventsBySubject(String subjectId) {
    return _firestore
        .collection(_collectionPath)
        .where('subjectId', isEqualTo: subjectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
    });
  }

  // Get upcoming events (from today onwards)
  Stream<List<CalendarEvent>> getUpcomingEvents() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    
    return _firestore
        .collection(_collectionPath)
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
    });
  }

  // Get events for specific month and year
  Stream<List<CalendarEvent>> getEventsForMonth(int month, int year) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = (month < 12) 
      ? DateTime(year, month + 1, 0)
      : DateTime(year + 1, 1, 0);

    return _firestore
        .collection(_collectionPath)
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
    });
  }
} 