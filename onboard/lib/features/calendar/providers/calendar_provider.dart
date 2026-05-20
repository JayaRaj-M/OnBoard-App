import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/tasks/providers/task_provider.dart';
import '../../../features/habits/providers/habit_provider.dart';
import '../../../features/notes/providers/note_provider.dart';

// ── Calendar currently-selected month ─────────────────────────────
class _MonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime(DateTime.now().year, DateTime.now().month);
  void set(DateTime dt) => state = dt;
}

final calendarMonthProvider =
    NotifierProvider<_MonthNotifier, DateTime>(_MonthNotifier.new);

// ── Calendar selected day ─────────────────────────────────────────
class _SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  void set(DateTime dt) => state = dt;
}

final calendarSelectedDayProvider =
    NotifierProvider<_SelectedDayNotifier, DateTime>(_SelectedDayNotifier.new);

// ── Events for a specific date ────────────────────────────────────
final calendarDayEventsProvider =
    Provider.family<List<CalendarEvent>, DateTime>((ref, date) {
  final tasks  = ref.watch(taskProvider);
  final habits = ref.watch(habitProvider);
  final notes  = ref.watch(noteProvider);

  final events = <CalendarEvent>[];

  // Tasks due on this day
  for (final task in tasks) {
    if (task.dueDate != null && _sameDay(task.dueDate!, date)) {
      events.add(CalendarEvent(
        title: task.title,
        type: CalendarEventType.task,
        isCompleted: task.isCompleted,
      ));
    }
  }

  // Habits completed on this day
  final isoDate =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  for (final habit in habits) {
    if (habit.history.contains(isoDate)) {
      events.add(CalendarEvent(
        title: habit.name,
        type: CalendarEventType.habit,
        isCompleted: true,
      ));
    }
  }

  // Notes updated on this day
  for (final note in notes) {
    if (_sameDay(note.updatedAt, date)) {
      events.add(CalendarEvent(
        title: note.title.isNotEmpty ? note.title : 'Note',
        type: CalendarEventType.note,
        isCompleted: false,
      ));
    }
  }

  return events;
});

// ── Helper ────────────────────────────────────────────────────────
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// ── Dots indicator for a month ────────────────────────────────────
final calendarMonthDotsProvider =
    Provider.family<Set<int>, DateTime>((ref, month) {
  final tasks  = ref.watch(taskProvider);
  final habits = ref.watch(habitProvider);

  final days = <int>{};
  for (final task in tasks) {
    if (task.dueDate != null &&
        task.dueDate!.year == month.year &&
        task.dueDate!.month == month.month) {
      days.add(task.dueDate!.day);
    }
  }
  for (final habit in habits) {
    for (final dateStr in habit.history) {
      final d = DateTime.parse(dateStr);
      if (d.year == month.year && d.month == month.month) days.add(d.day);
    }
  }
  return days;
});

// ── Event model ───────────────────────────────────────────────────
enum CalendarEventType { task, habit, note }

class CalendarEvent {
  final String title;
  final CalendarEventType type;
  final bool isCompleted;
  const CalendarEvent({
    required this.title,
    required this.type,
    required this.isCompleted,
  });
}
