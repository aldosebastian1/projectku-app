import 'package:cloud_firestore/cloud_firestore.dart';

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
    );
  }

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Project.fromMap(data, doc.id);
  }
}
