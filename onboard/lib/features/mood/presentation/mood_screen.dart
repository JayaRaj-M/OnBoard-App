import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../data/mood_model.dart';
import '../providers/mood_provider.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(moodProvider.notifier);
    ref.watch(moodProvider);
    final todaysMood = notifier.todaysMood;
    final last7 = notifier.last7Days;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.lg),
            _buildHeader(todaysMood),
            const SizedBox(height: AppSizes.lg),
            _buildMoodSelector(context, ref, todaysMood),
            const SizedBox(height: AppSizes.xl),
            _buildHistorySection(last7),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MoodEntry? todaysMood) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (b) =>
                AppColors.moodGradient.createShader(b),
            child: const Text(
              AppStrings.moodTitle,
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
            todaysMood != null
                ? 'You\'re feeling ${todaysMood.label.toLowerCase()} today ${todaysMood.emoji}'
                : AppStrings.howFeeling,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      );

  Widget _buildMoodSelector(
      BuildContext context, WidgetRef ref, MoodEntry? current) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final rating = i + 1;
              final entry = MoodEntry(
                  id: '', rating: rating, timestamp: DateTime.now());
              final isSelected = current?.rating == rating;

              return GestureDetector(
                onTap: () => _logMood(ref, rating),
                child: AnimatedContainer(
                  duration: AppSizes.animNormal,
                  width: isSelected ? 68 : 56,
                  height: isSelected ? 68 : 56,
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.moodGradient : null,
                    color: isSelected ? null : AppColors.surfaceHigh,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.moodStart.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      entry.emoji,
                      style: TextStyle(
                          fontSize: isSelected ? 32 : 26),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Awful', 'Bad', 'Okay', 'Good', 'Great']
                .map((label) => SizedBox(
                      width: 56,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  void _logMood(WidgetRef ref, int rating) {
    final entry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      rating: rating,
      timestamp: DateTime.now(),
    );
    ref.read(moodProvider.notifier).logMood(entry);
  }

  Widget _buildHistorySection(List<MoodEntry?> last7) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.moodHistory,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _buildMoodChart(last7),
          const SizedBox(height: AppSizes.md),
          _buildMoodLegend(last7),
        ],
      );

  Widget _buildMoodChart(List<MoodEntry?> last7) => Container(
        height: 140,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(color: AppColors.border),
        ),
        child: CustomPaint(
          painter: _MoodChartPainter(last7),
          size: Size.infinite,
        ),
      );

  Widget _buildMoodLegend(List<MoodEntry?> last7) {
    final now = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = now.subtract(Duration(days: 6 - i));
        final entry = last7[i];
        return Column(
          children: [
            Text(
              entry?.emoji ?? '·',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.dayNameShort(day),
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        );
      }),
    );
  }
}

// ── Mood Chart Painter ────────────────────────────────────────────
class _MoodChartPainter extends CustomPainter {
  final List<MoodEntry?> entries;
  _MoodChartPainter(this.entries);

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.every((e) => e == null)) return;

    final points = <Offset>[];
    final width = size.width;
    final height = size.height;

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (entry == null) continue;
      final x = i * width / (entries.length - 1);
      final y = height - (entry.rating / 5) * height;
      points.add(Offset(x, y));
    }

    if (points.length < 2) return;

    // Draw filled area
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (final pt in points) {
      fillPath.lineTo(pt.dx, pt.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.moodStart.withOpacity(0.4),
          AppColors.moodStart.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final cur = points[i];
      final mid = Offset((prev.dx + cur.dx) / 2, (prev.dy + cur.dy) / 2);
      linePath.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    linePath.lineTo(points.last.dx, points.last.dy);

    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.moodStart, AppColors.moodEnd],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = AppColors.moodEnd
      ..style = PaintingStyle.fill;
    for (final pt in points) {
      canvas.drawCircle(pt, 5, dotPaint);
      canvas.drawCircle(
          pt,
          3,
          Paint()
            ..color = AppColors.surface
            ..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(_MoodChartPainter old) => true;
}
