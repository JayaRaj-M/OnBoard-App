import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_storage_service.dart';
import '../data/note_model.dart';

class NoteNotifier extends Notifier<List<Note>> {
  @override
  List<Note> build() {
    final raw = localStorageService.loadNotes();
    return raw.map(Note.fromJson).toList();
  }

  void _save() {
    localStorageService.saveNotes(state.map((n) => n.toJson()).toList());
  }

  void addNote(Note note) {
    state = [note, ...state];
    _save();
  }

  void updateNote(Note updated) {
    state = state.map((n) => n.id == updated.id ? updated : n).toList();
    _save();
  }

  void deleteNote(String id) {
    state = state.where((n) => n.id != id).toList();
    _save();
  }

  List<Note> search(String query) {
    if (query.trim().isEmpty) return state;
    final q = query.toLowerCase();
    return state.where((n) {
      return n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q);
    }).toList();
  }
}

final noteProvider = NotifierProvider<NoteNotifier, List<Note>>(
  NoteNotifier.new,
);
