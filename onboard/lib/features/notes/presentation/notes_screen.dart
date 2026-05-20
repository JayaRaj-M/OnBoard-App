import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../data/note_model.dart';
import '../providers/note_provider.dart';

class _SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String q) => state = q;
}

final _searchQueryProvider =
    NotifierProvider<_SearchQueryNotifier, String>(_SearchQueryNotifier.new);


class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(_searchQueryProvider);
    final notifier = ref.watch(noteProvider.notifier);
    final notes = query.isEmpty
        ? ref.watch(noteProvider)
        : notifier.search(query);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchBar(ref),
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Text(
                      query.isEmpty
                          ? AppStrings.noNotes
                          : 'No notes match "$query"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                          height: 1.7),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSizes.sm,
                      crossAxisSpacing: AppSizes.sm,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: notes.length,
                    itemBuilder: (ctx, i) =>
                        _NoteCard(note: notes[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteEditor(context, ref, null),
        backgroundColor: AppColors.notesStart,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.lg, AppSizes.xl, AppSizes.lg, AppSizes.sm),
        child: ShaderMask(
          shaderCallback: (b) =>
              AppColors.notesGradient.createShader(b),
          child: const Text(
            AppStrings.notesTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      );

  Widget _buildSearchBar(WidgetRef ref) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.lg, 0, AppSizes.lg, AppSizes.md),
        child: TextField(
          onChanged: (v) =>
              ref.read(_searchQueryProvider.notifier).set(v),
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: AppStrings.searchNotes,
            hintStyle: const TextStyle(
                color: AppColors.textMuted, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textMuted, size: 20),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppSizes.radiusMd),
              borderSide:
                  const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppSizes.radiusMd),
              borderSide:
                  const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(
                  color: AppColors.notesStart, width: 1.5),
            ),
          ),
        ),
      );

  void _showNoteEditor(
      BuildContext context, WidgetRef ref, Note? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NoteEditorSheet(ref: ref, existing: existing),
    );
  }
}

// ── Note Card ─────────────────────────────────────────────────────
class _NoteCard extends ConsumerWidget {
  final Note note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.noteColors[
        note.colorIndex % AppColors.noteColors.length];

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _NoteEditorSheet(ref: ref, existing: note),
        );
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Delete note?',
                style: TextStyle(color: AppColors.textPrimary)),
            content: const Text(
                'This action cannot be undone.',
                style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(AppStrings.cancel,
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(noteProvider.notifier)
                      .deleteNote(note.id);
                  Navigator.pop(ctx);
                },
                child: Text(AppStrings.delete,
                    style: TextStyle(
                        color: AppColors.priorityHigh)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
              color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.title.isNotEmpty)
              Text(
                note.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                note.content,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
                overflow: TextOverflow.fade,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormatter.noteTimestamp(note.updatedAt),
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Note Editor Sheet ─────────────────────────────────────────────
class _NoteEditorSheet extends StatefulWidget {
  final WidgetRef ref;
  final Note? existing;
  const _NoteEditorSheet({required this.ref, this.existing});

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late int _colorIndex;

  @override
  void initState() {
    super.initState();
    _titleCtrl =
        TextEditingController(text: widget.existing?.title ?? '');
    _contentCtrl =
        TextEditingController(text: widget.existing?.content ?? '');
    _colorIndex = widget.existing?.colorIndex ?? 0;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final note = Note(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      updatedAt: DateTime.now(),
      colorIndex: _colorIndex,
    );
    if (widget.existing == null) {
      widget.ref.read(noteProvider.notifier).addNote(note);
    } else {
      widget.ref.read(noteProvider.notifier).updateNote(note);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXxl)),
        ),
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            // Color picker
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppColors.noteColors.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() => _colorIndex = i),
                  child: AnimatedContainer(
                    duration: AppSizes.animFast,
                    margin: const EdgeInsets.only(right: 8),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.noteColors[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _colorIndex == i
                            ? AppColors.notesStart
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                hintText: AppStrings.noteTitle,
                hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
                border: InputBorder.none,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                expands: true,
                autofocus: widget.existing == null,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
                decoration: const InputDecoration(
                  hintText: AppStrings.noteContent,
                  hintStyle: TextStyle(
                      color: AppColors.textMuted, fontSize: 15),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.notesGradient,
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  child: const Text(
                    AppStrings.save,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
