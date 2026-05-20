import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_storage_service.dart';
import '../data/transaction_model.dart';

class FinanceNotifier extends Notifier<List<Transaction>> {
  @override
  List<Transaction> build() {
    final raw = localStorageService.loadTransactions();
    return raw.map(Transaction.fromJson).toList();
  }

  void _save() {
    localStorageService
        .saveTransactions(state.map((t) => t.toJson()).toList());
  }

  void addTransaction(Transaction transaction) {
    state = [transaction, ...state];
    _save();
  }

  void deleteTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
    _save();
  }

  // ── Computed values ───────────────────────────────────────────
  double get totalIncome => state
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => state
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

  // Spending by category (expenses only)
  Map<TransactionCategory, double> get categoryTotals {
    final map = <TransactionCategory, double>{};
    for (final t in state.where((t) => t.isExpense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  // Recent transactions (last 10)
  List<Transaction> get recentTransactions => state.take(10).toList();
}

final financeProvider = NotifierProvider<FinanceNotifier, List<Transaction>>(
  FinanceNotifier.new,
);
