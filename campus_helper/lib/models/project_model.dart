import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectStatus {
  planning,
  inProgress,
  onHold,
  completed,
  cancelled
}

enum TaskStatus {
  todo,
  inProgress,
  underReview,
  completed
}

class Project {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String? subjectName;
  final DateTime startDate;
  final DateTime deadline;
  final ProjectStatus status;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> teamMemberIds;
  final List<Map<String, dynamic>> teamMembers; // name, email, role, etc.
  final List<ProjectTask> tasks; // Sub-tasks for the project
  final List<String> fileUrls; // Project attachments/documents
  final Map<String, dynamic>? metaData; // Additional project info
  final double progress; // Overall progress percentage

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    this.subjectName,
    required this.startDate,
    required this.deadline,
    required this.status,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    required this.teamMemberIds,
    required this.teamMembers,
    required this.tasks,
    required this.fileUrls,
    this.metaData,
    required this.progress,
  });

  // Factory constructor to create a Project from Firestore data
  factory Project.fromFirestore(DocumentSnapshot doc, List<ProjectTask> tasks) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Parse project status from string
    ProjectStatus projectStatus;
    try {
      projectStatus = ProjectStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] ?? 'planning'),
        orElse: () => ProjectStatus.planning,
      );
    } catch (e) {
      projectStatus = ProjectStatus.planning;
    }

    return Project(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      deadline: (data['deadline'] as Timestamp).toDate(),
      status: projectStatus,
      createdById: data['createdById'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      teamMemberIds: List<String>.from(data['teamMemberIds'] ?? []),
      teamMembers: List<Map<String, dynamic>>.from(data['teamMembers'] ?? []),
      tasks: tasks,
      fileUrls: List<String>.from(data['fileUrls'] ?? []),
      metaData: data['metaData'],
      progress: (data['progress'] ?? 0.0).toDouble(),
    );
  }

  // Convert Project to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'startDate': Timestamp.fromDate(startDate),
      'deadline': Timestamp.fromDate(deadline),
      'status': status.toString().split('.').last,
      'createdById': createdById,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'teamMemberIds': teamMemberIds,
      'teamMembers': teamMembers,
      'fileUrls': fileUrls,
      'metaData': metaData,
      'progress': progress,
    };
  }

  // Create a copy of this Project with modified fields
  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? subjectId,
    String? subjectName,
    DateTime? startDate,
    DateTime? deadline,
    ProjectStatus? status,
    String? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? teamMemberIds,
    List<Map<String, dynamic>>? teamMembers,
    List<ProjectTask>? tasks,
    List<String>? fileUrls,
    Map<String, dynamic>? metaData,
    double? progress,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      teamMemberIds: teamMemberIds ?? this.teamMemberIds,
      teamMembers: teamMembers ?? this.teamMembers,
      tasks: tasks ?? this.tasks,
      fileUrls: fileUrls ?? this.fileUrls,
      metaData: metaData ?? this.metaData,
      progress: progress ?? this.progress,
    );
  }

  // Calculate days remaining until deadline
  int getDaysRemaining() {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }

  // Check if the project is overdue
  bool isOverdue() {
    final now = DateTime.now();
    return now.isAfter(deadline) && status != ProjectStatus.completed;
  }

  // Get project status as a formatted string
  String getStatusString() {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  // Calculate project progress based on completed tasks
  double calculateProgress() {
    if (tasks.isEmpty) return 0.0;
    
    int completedTasks = tasks.where((task) => 
      task.status == TaskStatus.completed).length;
    
    return (completedTasks / tasks.length) * 100;
  }
}

class ProjectTask {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String assignedToId;
  final String assignedToName;
  final DateTime createdAt;
  final DateTime dueDate;
  final TaskStatus status;
  final int priority; // 1-3 (low, medium, high)
  final List<String> dependsOn; // IDs of tasks this task depends on
  final List<String> comments;
  final List<String> fileUrls;
  final int estimatedHours;
  final int loggedHours;

  ProjectTask({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.assignedToId,
    required this.assignedToName,
    required this.createdAt,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.dependsOn,
    required this.comments,
    required this.fileUrls,
    required this.estimatedHours,
    required this.loggedHours,
  });

  // Factory constructor to create a ProjectTask from Firestore data
  factory ProjectTask.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Parse task status from string
    TaskStatus taskStatus;
    try {
      taskStatus = TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] ?? 'todo'),
        orElse: () => TaskStatus.todo,
      );
    } catch (e) {
      taskStatus = TaskStatus.todo;
    }

    return ProjectTask(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedToId: data['assignedToId'] ?? '',
      assignedToName: data['assignedToName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: taskStatus,
      priority: data['priority'] ?? 2,
      dependsOn: List<String>.from(data['dependsOn'] ?? []),
      comments: List<String>.from(data['comments'] ?? []),
      fileUrls: List<String>.from(data['fileUrls'] ?? []),
      estimatedHours: data['estimatedHours'] ?? 0,
      loggedHours: data['loggedHours'] ?? 0,
    );
  }

  // Convert ProjectTask to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status.toString().split('.').last,
      'priority': priority,
      'dependsOn': dependsOn,
      'comments': comments,
      'fileUrls': fileUrls,
      'estimatedHours': estimatedHours,
      'loggedHours': loggedHours,
    };
  }

  // Create a copy of this ProjectTask with modified fields
  ProjectTask copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? assignedToId,
    String? assignedToName,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskStatus? status,
    int? priority,
    List<String>? dependsOn,
    List<String>? comments,
    List<String>? fileUrls,
    int? estimatedHours,
    int? loggedHours,
  }) {
    return ProjectTask(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dependsOn: dependsOn ?? this.dependsOn,
      comments: comments ?? this.comments,
      fileUrls: fileUrls ?? this.fileUrls,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      loggedHours: loggedHours ?? this.loggedHours,
    );
  }

  // Check if this task is overdue
  bool isOverdue() {
    final now = DateTime.now();
    return now.isAfter(dueDate) && status != TaskStatus.completed;
  }

  // Get days remaining until due date
  int getDaysRemaining() {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    return difference.inDays;
  }

  // Get the priority level as a string
  String getPriorityString() {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Medium';
    }
  }

  // Get the status as a formatted string
  String getStatusString() {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.underReview:
        return 'Under Review';
      case TaskStatus.completed:
        return 'Completed';
      default:
        return 'To Do';
    }
  }
} 