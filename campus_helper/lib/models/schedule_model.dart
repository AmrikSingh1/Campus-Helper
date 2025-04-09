import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String name;
  final String? description;
  final String creatorId;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ScheduleEvent> events;

  Schedule({
    required this.id,
    required this.name,
    this.description,
    required this.creatorId,
    this.isPublic = false,
    required this.createdAt,
    required this.updatedAt,
    required this.events,
  });

  factory Schedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Schedule(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      creatorId: data['creatorId'] ?? '',
      isPublic: data['isPublic'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      events: (data['events'] as List<dynamic>?)
              ?.map((e) => ScheduleEvent.fromMap(e as Map<String, dynamic>))
              .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'events': events.map((e) => e.toMap()).toList(),
    };
  }

  Schedule copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ScheduleEvent>? events,
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      events: events ?? this.events,
    );
  }

  List<ScheduleEvent> getUpcomingEvents() {
    final now = DateTime.now();
    return events
        .where((event) => event.endTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
}

class ScheduleEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String? color;
  final bool isRecurring;
  final String? recurrenceRule;

  ScheduleEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    this.color,
    this.isRecurring = false,
    this.recurrenceRule,
  });

  factory ScheduleEvent.fromMap(Map<String, dynamic> map) {
    return ScheduleEvent(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      location: map['location'],
      color: map['color'],
      isRecurring: map['isRecurring'] ?? false,
      recurrenceRule: map['recurrenceRule'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'color': color,
      'isRecurring': isRecurring,
      'recurrenceRule': recurrenceRule,
    };
  }

  ScheduleEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? color,
    bool? isRecurring,
    String? recurrenceRule,
  }) {
    return ScheduleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      color: color ?? this.color,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
    );
  }
} 