import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/providers/task_provider.dart';
import '../../habits/providers/habit_provider.dart';
import '../../mood/providers/mood_provider.dart';
import '../../finance/providers/finance_provider.dart';

// ── Active navigation index (0 = Dashboard, 1-6 = feature pages) ──
class _NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int i) => state = i;
}

final dashboardIndexProvider =
    NotifierProvider<_NavIndexNotifier, int>(_NavIndexNotifier.new);

// ── Aggregated stats for the dashboard overview ────────────────────
class DashboardStats {
  final int pendingTasks;
  final int habitsCompletedToday;
  final int totalHabits;
  final double balance;
  final String? todayMoodEmoji;

  const DashboardStats({
    required this.pendingTasks,
    required this.habitsCompletedToday,
    required this.totalHabits,
    required this.balance,
    this.todayMoodEmoji,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final tasks   = ref.watch(taskProvider.notifier);
  final habits  = ref.watch(habitProvider.notifier);
  final mood    = ref.watch(moodProvider.notifier);
  final finance = ref.watch(financeProvider.notifier);

  // Watch the state to trigger rebuilds
  ref.watch(taskProvider);
  ref.watch(habitProvider);
  ref.watch(moodProvider);
  ref.watch(financeProvider);

  return DashboardStats(
    pendingTasks: tasks.pendingCount,
    habitsCompletedToday: habits.completedTodayCount,
    totalHabits: habits.totalCount,
    balance: finance.balance,
    todayMoodEmoji: mood.todaysMood?.emoji,
  );
});
