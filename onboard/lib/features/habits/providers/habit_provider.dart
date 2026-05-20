import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_storage_service.dart';
import '../data/habit_model.dart';

class HabitNotifier extends Notifier<List<Habit>> {
  @override
  List<Habit> build() {
    final raw = localStorageService.loadHabits();
    return raw.map(Habit.fromJson).toList();
  }

  void _save() {
    localStorageService.saveHabits(state.map((h) => h.toJson()).toList());
  }

  void addHabit(Habit habit) {
    state = [habit, ...state];
    _save();
  }

  void deleteHabit(String id) {
    state = state.where((h) => h.id != id).toList();
    _save();
  }

  void toggleToday(String id) {
    final today = _isoToday();
    state = state.map((h) {
      if (h.id != id) return h;
      final alreadyDone = h.history.contains(today);
      final newHistory = alreadyDone
          ? (List<String>.from(h.history)..remove(today))
          : (List<String>.from(h.history)..add(today));

      // Recalculate streak
      int streak = 0;
      if (!alreadyDone) {
        // Adding today — count consecutive days backwards
        streak = _calculateStreak(newHistory);
      } else {
        streak = _calculateStreak(newHistory);
      }

      return h.copyWith(history: newHistory, streakCount: streak);
    }).toList();
    _save();
  }

  int _calculateStreak(List<String> history) {
    if (history.isEmpty) return 0;
    final sorted = List<String>.from(history)..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime current = DateTime.now();
    for (final dateStr in sorted) {
      final date = DateTime.parse(dateStr);
      final diff = DateTime(current.year, current.month, current.day)
          .difference(DateTime(date.year, date.month, date.day))
          .inDays;
      if (diff == 0 || diff == streak) {
        streak++;
        current = date;
      } else {
        break;
      }
    }
    return streak;
  }

  static String _isoToday() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int get completedTodayCount =>
      state.where((h) => h.isCompletedToday).length;
  int get totalCount => state.length;
}

final habitProvider = NotifierProvider<HabitNotifier, List<Habit>>(
  HabitNotifier.new,
);
