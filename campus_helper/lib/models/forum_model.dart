import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final int upvotes;
  final int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final int views;
  final int commentCount;
  final bool isPinned;
  final String? subjectId;
  final String category; // general, academic, events, etc.
  final bool isSolved; // For Q&A style posts

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.upvotes,
    required this.downvotes,
    required this.upvotedBy,
    required this.downvotedBy,
    required this.views,
    required this.commentCount,
    required this.isPinned,
    this.subjectId,
    required this.category,
    required this.isSolved,
  });

  // Factory constructor to create a ForumPost from Firestore data
  factory ForumPost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ForumPost(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorImageUrl: data['authorImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      upvotedBy: List<String>.from(data['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(data['downvotedBy'] ?? []),
      views: data['views'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      isPinned: data['isPinned'] ?? false,
      subjectId: data['subjectId'],
      category: data['category'] ?? 'general',
      isSolved: data['isSolved'] ?? false,
    );
  }

  // Convert ForumPost to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
      'views': views,
      'commentCount': commentCount,
      'isPinned': isPinned,
      'subjectId': subjectId,
      'category': category,
      'isSolved': isSolved,
    };
  }

  // Create a copy of this ForumPost with modified fields
  ForumPost copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? authorImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    int? upvotes,
    int? downvotes,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
    int? views,
    int? commentCount,
    bool? isPinned,
    String? subjectId,
    String? category,
    bool? isSolved,
  }) {
    return ForumPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
      views: views ?? this.views,
      commentCount: commentCount ?? this.commentCount,
      isPinned: isPinned ?? this.isPinned,
      subjectId: subjectId ?? this.subjectId,
      category: category ?? this.category,
      isSolved: isSolved ?? this.isSolved,
    );
  }

  // Get post age as a readable string
  String getPostAge() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Get post score (upvotes - downvotes)
  int getScore() {
    return upvotes - downvotes;
  }
}

class ForumComment {
  final String id;
  final String postId;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int upvotes;
  final int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final String? parentCommentId; // For nested comments/replies
  final bool isAcceptedAnswer; // For Q&A style posts

  ForumComment({
    required this.id,
    required this.postId,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.upvotes,
    required this.downvotes,
    required this.upvotedBy,
    required this.downvotedBy,
    this.parentCommentId,
    required this.isAcceptedAnswer,
  });

  // Factory constructor to create a ForumComment from Firestore data
  factory ForumComment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ForumComment(
      id: doc.id,
      postId: data['postId'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorImageUrl: data['authorImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      upvotedBy: List<String>.from(data['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(data['downvotedBy'] ?? []),
      parentCommentId: data['parentCommentId'],
      isAcceptedAnswer: data['isAcceptedAnswer'] ?? false,
    );
  }

  // Convert ForumComment to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
      'parentCommentId': parentCommentId,
      'isAcceptedAnswer': isAcceptedAnswer,
    };
  }

  // Create a copy of this ForumComment with modified fields
  ForumComment copyWith({
    String? id,
    String? postId,
    String? content,
    String? authorId,
    String? authorName,
    String? authorImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? upvotes,
    int? downvotes,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
    String? parentCommentId,
    bool? isAcceptedAnswer,
  }) {
    return ForumComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      isAcceptedAnswer: isAcceptedAnswer ?? this.isAcceptedAnswer,
    );
  }

  // Get comment age as a readable string
  String getCommentAge() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Get comment score (upvotes - downvotes)
  int getScore() {
    return upvotes - downvotes;
  }
} 