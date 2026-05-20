import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_storage_service.dart';
import '../data/mood_model.dart';

class MoodNotifier extends Notifier<List<MoodEntry>> {
  @override
  List<MoodEntry> build() {
    final raw = localStorageService.loadMoods();
    return raw.map(MoodEntry.fromJson).toList();
  }

  void _save() {
    localStorageService.saveMoods(state.map((m) => m.toJson()).toList());
  }

  void logMood(MoodEntry entry) {
    // Replace today's entry if one already exists
    final today = entry.timestamp;
    final filtered = state.where((m) {
      return !(m.timestamp.year == today.year &&
          m.timestamp.month == today.month &&
          m.timestamp.day == today.day);
    }).toList();
    state = [entry, ...filtered];
    _save();
  }

  void deleteMood(String id) {
    state = state.where((m) => m.id != id).toList();
    _save();
  }

  MoodEntry? get todaysMood {
    final now = DateTime.now();
    try {
      return state.firstWhere(
        (m) =>
            m.timestamp.year == now.year &&
            m.timestamp.month == now.month &&
            m.timestamp.day == now.day,
      );
    } catch (_) {
      return null;
    }
  }

  double get weeklyAverage {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = state.where((m) => m.timestamp.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0;
    return recent.map((m) => m.rating).reduce((a, b) => a + b) /
        recent.length;
  }

  // Last 7 days' ratings for chart
  List<MoodEntry?> get last7Days {
    return List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      try {
        return state.firstWhere(
          (m) =>
              m.timestamp.year == day.year &&
              m.timestamp.month == day.month &&
              m.timestamp.day == day.day,
        );
      } catch (_) {
        return null;
      }
    });
  }
}

final moodProvider = NotifierProvider<MoodNotifier, List<MoodEntry>>(
  MoodNotifier.new,
);
