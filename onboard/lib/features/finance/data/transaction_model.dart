import 'package:flutter/foundation.dart';

enum TransactionCategory {
  income,
  food,
  transport,
  bills,
  shopping,
  leisure,
  other,
}

extension TransactionCategoryX on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.income:    return 'Income';
      case TransactionCategory.food:      return 'Food';
      case TransactionCategory.transport: return 'Transport';
      case TransactionCategory.bills:     return 'Bills';
      case TransactionCategory.shopping:  return 'Shopping';
      case TransactionCategory.leisure:   return 'Leisure';
      case TransactionCategory.other:     return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case TransactionCategory.income:    return '💰';
      case TransactionCategory.food:      return '🍽️';
      case TransactionCategory.transport: return '🚌';
      case TransactionCategory.bills:     return '📄';
      case TransactionCategory.shopping:  return '🛍️';
      case TransactionCategory.leisure:   return '🎮';
      case TransactionCategory.other:     return '📦';
    }
  }
}

@immutable
class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionCategory category;
  final bool isExpense;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isExpense,
  });

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionCategory? category,
    bool? isExpense,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      isExpense: isExpense ?? this.isExpense,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category.index,
        'isExpense': isExpense,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        category: TransactionCategory.values[json['category'] as int? ?? 0],
        isExpense: json['isExpense'] as bool? ?? true,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Transaction && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
