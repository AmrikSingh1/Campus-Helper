import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final String ownerName;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final List<String> participants;

  Schedule({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.ownerName,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.isPublic,
    required this.participants,
  });

  factory Schedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Schedule(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] ?? false,
      participants: List<String>.from(data['participants'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublic': isPublic,
      'participants': participants,
    };
  }

  Schedule copyWith({
    String? title,
    String? description,
    DateTime? date,
    bool? isPublic,
  }) {
    return Schedule(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      ownerId: ownerId,
      ownerName: ownerName,
      date: date ?? this.date,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isPublic: isPublic ?? this.isPublic,
      participants: participants,
    );
  }
} 