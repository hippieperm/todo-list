import 'package:uuid/uuid.dart';

class Todo {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;
  int priority; // 1: 낮음, 2: 중간, 3: 높음

  Todo({
    String? id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    this.priority = 2,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    int? priority,
  }) {
    return Todo(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
    );
  }

  // SQLite를 위한 Map 변환 메서드
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'priority': priority,
    };
  }

  // SQLite에서 가져온 Map을 Todo 객체로 변환하는 팩토리 메서드
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      priority: map['priority'],
    );
  }
}
