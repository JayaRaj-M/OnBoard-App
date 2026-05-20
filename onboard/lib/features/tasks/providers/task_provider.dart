import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_storage_service.dart';
import '../data/task_model.dart';

class TaskNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    final raw = localStorageService.loadTasks();
    return raw.map(Task.fromJson).toList();
  }

  void _save() {
    localStorageService.saveTasks(state.map((t) => t.toJson()).toList());
  }

  void addTask(Task task) {
    state = [task, ...state];
    _save();
  }

  void toggleComplete(String id) {
    state = state.map((t) {
      if (t.id == id) return t.copyWith(isCompleted: !t.isCompleted);
      return t;
    }).toList();
    _save();
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
    _save();
  }

  void updateTask(Task updated) {
    state = state.map((t) => t.id == updated.id ? updated : t).toList();
    _save();
  }

  // ── Derived getters ──────────────────────────────────────────
  List<Task> get activeTasks => state.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => state.where((t) => t.isCompleted).toList();
  int get pendingCount => activeTasks.length;
}

final taskProvider = NotifierProvider<TaskNotifier, List<Task>>(
  TaskNotifier.new,
);
