import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A thin wrapper around SharedPreferences for JSON-based persistence.
class LocalStorageService {
  late final SharedPreferences _prefs;

  // ── Storage keys ──────────────────────────────────────────────
  static const String keyTasks        = 'tasks_v1';
  static const String keyHabits       = 'habits_v1';
  static const String keyNotes        = 'notes_v1';
  static const String keyMoods        = 'moods_v1';
  static const String keyTransactions = 'transactions_v1';

  // ── Initialise (called once in main()) ───────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Generic read / write ──────────────────────────────────────
  Future<void> saveList(String key, List<Map<String, dynamic>> list) async {
    await _prefs.setString(key, jsonEncode(list));
  }

  List<Map<String, dynamic>> loadList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  // ── Tasks ─────────────────────────────────────────────────────
  Future<void> saveTasks(List<Map<String, dynamic>> tasks) =>
      saveList(keyTasks, tasks);

  List<Map<String, dynamic>> loadTasks() => loadList(keyTasks);

  // ── Habits ────────────────────────────────────────────────────
  Future<void> saveHabits(List<Map<String, dynamic>> habits) =>
      saveList(keyHabits, habits);

  List<Map<String, dynamic>> loadHabits() => loadList(keyHabits);

  // ── Notes ─────────────────────────────────────────────────────
  Future<void> saveNotes(List<Map<String, dynamic>> notes) =>
      saveList(keyNotes, notes);

  List<Map<String, dynamic>> loadNotes() => loadList(keyNotes);

  // ── Moods ─────────────────────────────────────────────────────
  Future<void> saveMoods(List<Map<String, dynamic>> moods) =>
      saveList(keyMoods, moods);

  List<Map<String, dynamic>> loadMoods() => loadList(keyMoods);

  // ── Transactions ──────────────────────────────────────────────
  Future<void> saveTransactions(List<Map<String, dynamic>> transactions) =>
      saveList(keyTransactions, transactions);

  List<Map<String, dynamic>> loadTransactions() =>
      loadList(keyTransactions);
}

/// Global instance — injected via Riverpod override in main().
final localStorageService = LocalStorageService();
