import 'package:flutter/foundation.dart';

@immutable
class Habit {
  final String id;
  final String name;
  final String emoji;
  final int streakCount;
  final List<String> history; // ISO date strings e.g. ["2026-05-20"]
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.name,
    this.emoji = '⭐',
    this.streakCount = 0,
    this.history = const [],
    required this.createdAt,
  });

  bool get isCompletedToday {
    final today = _isoToday();
    return history.contains(today);
  }

  static String _isoToday() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Habit copyWith({
    String? id,
    String? name,
    String? emoji,
    int? streakCount,
    List<String>? history,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      streakCount: streakCount ?? this.streakCount,
      history: history ?? this.history,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'streakCount': streakCount,
        'history': history,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String? ?? '⭐',
        streakCount: json['streakCount'] as int? ?? 0,
        history: (json['history'] as List<dynamic>?)
                ?.cast<String>() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Habit && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
