import 'package:flutter/foundation.dart';

@immutable
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;
  final int colorIndex; // index into AppColors.noteColors

  const Note({
    required this.id,
    required this.title,
    this.content = '',
    required this.updatedAt,
    this.colorIndex = 0,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? updatedAt,
    int? colorIndex,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
        'colorIndex': colorIndex,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String? ?? '',
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        colorIndex: json['colorIndex'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Note && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
