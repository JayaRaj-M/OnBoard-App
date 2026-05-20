import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../data/habit_model.dart';
import '../providers/habit_provider.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final notifier = ref.watch(habitProvider.notifier);
    final total = notifier.totalCount;
    final done = notifier.completedTodayCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(done, total),
          if (total > 0) _buildProgressRing(done, total),
          Expanded(
            child: habits.isEmpty
                ? const Center(
                    child: Text(
                      AppStrings.noHabits,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                          height: 1.7),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    itemCount: habits.length,
                    itemBuilder: (ctx, i) => _HabitCard(habit: habits[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitSheet(context, ref),
        backgroundColor: AppColors.habitsStart,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(int done, int total) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.lg, AppSizes.xl, AppSizes.lg, AppSizes.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (b) =>
                  AppColors.habitsGradient.createShader(b),
              child: const Text(
                AppStrings.habitsTitle,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$done / $total ${AppStrings.completedToday}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );

  Widget _buildProgressRing(int done, int total) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _RingPainter(
                    progress: total == 0 ? 0 : done / total,
                    gradient: AppColors.habitsGradient,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$done',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'of $total',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  void _showAddHabitSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddHabitSheet(ref: ref),
    );
  }
}

// ── Progress ring painter ─────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final LinearGradient gradient;

  _RingPainter({required this.progress, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final rect =
          Rect.fromCircle(center: center, radius: radius);
      final shader = gradient.createShader(rect);
      final fgPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Habit Card ────────────────────────────────────────────────────
class _HabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  const _HabitCard({required this.habit});

  @override
  ConsumerState<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<_HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: AppSizes.animFast,
    );
    _scaleAnim =
        Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    _animCtrl.forward().then((_) => _animCtrl.reverse());
    ref.read(habitProvider.notifier).toggleToday(widget.habit.id);
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final done = habit.isCompletedToday;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Dismissible(
        key: Key(habit.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSizes.lg),
          decoration: BoxDecoration(
            color: AppColors.priorityHigh.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: AppColors.priorityHigh),
        ),
        onDismissed: (_) =>
            ref.read(habitProvider.notifier).deleteHabit(habit.id),
        child: AnimatedContainer(
          duration: AppSizes.animNormal,
          decoration: BoxDecoration(
            color: done
                ? AppColors.habitsStart.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: done
                  ? AppColors.habitsStart.withOpacity(0.4)
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            leading: Text(habit.emoji,
                style: const TextStyle(fontSize: 28)),
            title: Text(
              habit.name,
              style: TextStyle(
                color: done
                    ? AppColors.habitsStart
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    size: 14, color: AppColors.moodStart),
                const SizedBox(width: 3),
                Text(
                  '${habit.streakCount} ${AppStrings.streakDays}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            trailing: ScaleTransition(
              scale: _scaleAnim,
              child: GestureDetector(
                onTap: _toggle,
                child: AnimatedContainer(
                  duration: AppSizes.animNormal,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: done ? AppColors.habitsGradient : null,
                    border: done
                        ? null
                        : Border.all(color: AppColors.border, width: 2),
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Add Habit Sheet ───────────────────────────────────────────────
class _AddHabitSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddHabitSheet({required this.ref});

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '⭐';

  static const emojis = [
    '⭐','💪','📚','🏃','🧘','💧','🥗','😴','🎯','🎨','🎵','💻','✍️','🌱','🙏'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) return;
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      emoji: _selectedEmoji,
      createdAt: DateTime.now(),
    );
    widget.ref.read(habitProvider.notifier).addHabit(habit);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXxl)),
        ),
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ShaderMask(
              shaderCallback: (b) =>
                  AppColors.habitsGradient.createShader(b),
              child: const Text(
                AppStrings.addHabit,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: AppStrings.habitName,
                hintStyle: const TextStyle(
                    color: AppColors.textMuted, fontSize: 15),
                filled: true,
                fillColor: AppColors.surfaceHigh,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(
                      color: AppColors.habitsStart, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const Text('Pick an emoji',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: emojis
                  .map((e) => GestureDetector(
                        onTap: () =>
                            setState(() => _selectedEmoji = e),
                        child: AnimatedContainer(
                          duration: AppSizes.animFast,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedEmoji == e
                                ? AppColors.habitsStart.withOpacity(0.2)
                                : AppColors.surfaceHigh,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSm),
                            border: Border.all(
                              color: _selectedEmoji == e
                                  ? AppColors.habitsStart
                                  : Colors.transparent,
                            ),
                          ),
                          child:
                              Text(e, style: const TextStyle(fontSize: 22)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSizes.lg),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.habitsGradient,
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
