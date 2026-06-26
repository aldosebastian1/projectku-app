import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectTask {
  final String title;
  final bool isCompleted;

  ProjectTask({
    required this.title,
    this.isCompleted = false,
  });

  ProjectTask copyWith({
    String? title,
    bool? isCompleted,
  }) {
    return ProjectTask(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory ProjectTask.fromMap(Map<String, dynamic> map) {
    return ProjectTask(
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class Project {
  final String id;
  final String name;
  final String clientName;
  final double budget;
  final DateTime dueDate;
  final String status; // 'In Progress', 'Completed', 'On Hold'
  final String paymentStatus; // 'Unpaid', 'Paid', 'Invoice Sent'
  final String description;
  final DateTime createdAt;
  final List<ProjectTask> tasks;

  Project({
    required this.id,
    required this.name,
    required this.clientName,
    required this.budget,
    required this.dueDate,
    required this.status,
    required this.paymentStatus,
    required this.description,
    required this.createdAt,
    this.tasks = const [],
  });

  Project copyWith({
    String? id,
    String? name,
    String? clientName,
    double? budget,
    DateTime? dueDate,
    String? status,
    String? paymentStatus,
    String? description,
    DateTime? createdAt,
    List<ProjectTask>? tasks,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      clientName: clientName ?? this.clientName,
      budget: budget ?? this.budget,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'clientName': clientName,
      'budget': budget,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'paymentStatus': paymentStatus,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'tasks': tasks.map((t) => t.toMap()).toList(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map, String documentId) {
    return Project(
      id: documentId,
      name: map['name'] ?? '',
      clientName: map['clientName'] ?? '',
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      dueDate: (map['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'In Progress',
      paymentStatus: map['paymentStatus'] ?? 'Unpaid',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tasks: (map['tasks'] as List<dynamic>?)
              ?.map((t) => ProjectTask.fromMap(Map<String, dynamic>.from(t as Map)))
              .toList() ??
          const [],
    );
  }

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Project.fromMap(data, doc.id);
  }
}
