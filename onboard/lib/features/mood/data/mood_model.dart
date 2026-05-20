import 'package:flutter/foundation.dart';

@immutable
class MoodEntry {
  final String id;
  final int rating; // 1 = awful, 2 = bad, 3 = okay, 4 = good, 5 = great
  final String note;
  final DateTime timestamp;

  const MoodEntry({
    required this.id,
    required this.rating,
    this.note = '',
    required this.timestamp,
  });

  String get emoji {
    switch (rating) {
      case 1: return '😞';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '😊';
      case 5: return '😄';
      default: return '😐';
    }
  }

  String get label {
    switch (rating) {
      case 1: return 'Awful';
      case 2: return 'Bad';
      case 3: return 'Okay';
      case 4: return 'Good';
      case 5: return 'Great';
      default: return 'Okay';
    }
  }

  MoodEntry copyWith({
    String? id,
    int? rating,
    String? note,
    DateTime? timestamp,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rating': rating,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        id: json['id'] as String,
        rating: json['rating'] as int,
        note: json['note'] as String? ?? '',
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MoodEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
