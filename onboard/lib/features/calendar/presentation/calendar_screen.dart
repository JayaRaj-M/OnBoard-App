import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/calendar_provider.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthProvider);
    final selectedDay = ref.watch(calendarSelectedDayProvider);
    final events = ref.watch(calendarDayEventsProvider(selectedDay));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, ref, month)),
            SliverToBoxAdapter(child: _buildWeekDayLabels()),
            SliverToBoxAdapter(
                child: _buildCalendarGrid(context, ref, month, selectedDay)),
            const SliverToBoxAdapter(
                child: Divider(color: AppColors.border, height: 1)),
            SliverToBoxAdapter(child: _buildEventsPanelHeader(selectedDay)),
            if (events.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.lg),
                  child: Text(
                    AppStrings.noEvents,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg, vertical: 4),
                    child: _EventTile(event: events[i]),
                  ),
                  childCount: events.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, DateTime month) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.lg, AppSizes.xl, AppSizes.lg, AppSizes.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (b) =>
                        AppColors.calendarGradient.createShader(b),
                    child: const Text(
                      AppStrings.calendarTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Text(
                    DateFormatter.monthYear(month),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            _NavButton(
              icon: Icons.chevron_left_rounded,
              onTap: () {
                ref.read(calendarMonthProvider.notifier).set(
                    DateTime(month.year, month.month - 1));
              },
            ),
            const SizedBox(width: AppSizes.sm),
            _NavButton(
              icon: Icons.chevron_right_rounded,
              onTap: () {
                ref.read(calendarMonthProvider.notifier).set(
                    DateTime(month.year, month.month + 1));
              },
            ),
          ],
        ),
      );

  Widget _buildWeekDayLabels() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        child: Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      );

  Widget _buildCalendarGrid(BuildContext context, WidgetRef ref,
      DateTime month, DateTime selectedDay) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateFormatter.daysInMonth(month.year, month.month);
    final startWeekday = firstDay.weekday % 7; // Sun=0
    final dots = ref.watch(calendarMonthDotsProvider(month));
    final today = DateTime.now();

    final cells = <Widget>[];

    // Empty cells before month start
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final isToday = DateFormatter.isSameDay(date, today);
      final isSelected = DateFormatter.isSameDay(date, selectedDay);
      final hasDot = dots.contains(day);

      cells.add(GestureDetector(
        onTap: () {
          ref.read(calendarSelectedDayProvider.notifier).set(date);
        },
        child: AnimatedContainer(
          duration: AppSizes.animFast,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.calendarGradient : null,
            color: isToday && !isSelected
                ? AppColors.calendarStart.withOpacity(0.15)
                : null,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: isToday && !isSelected
                ? Border.all(
                    color: AppColors.calendarStart.withOpacity(0.5), width: 1)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? AppColors.calendarStart
                          : AppColors.textPrimary,
                  fontWeight:
                      isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              if (hasDot) ...[
                const SizedBox(height: 2),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.white.withOpacity(0.8)
                        : AppColors.calendarStart,
                  ),
                ),
              ],
            ],
          ),
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1,
        children: cells,
      ),
    );
  }

  Widget _buildEventsPanelHeader(DateTime selectedDay) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.lg, AppSizes.md, AppSizes.lg, AppSizes.sm),
        child: Text(
          DateFormatter.relativeDay(selectedDay),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      );


}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
      );
}

class _EventTile extends StatelessWidget {
  final CalendarEvent event;
  const _EventTile({required this.event});

  Color get _typeColor {
    switch (event.type) {
      case CalendarEventType.task:  return AppColors.tasksStart;
      case CalendarEventType.habit: return AppColors.habitsStart;
      case CalendarEventType.note:  return AppColors.notesStart;
    }
  }

  IconData get _typeIcon {
    switch (event.type) {
      case CalendarEventType.task:  return Icons.check_box_outline_blank_rounded;
      case CalendarEventType.habit: return Icons.repeat_rounded;
      case CalendarEventType.note:  return Icons.sticky_note_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: _typeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: _typeColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(_typeIcon, color: _typeColor, size: 18),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                event.title,
                style: TextStyle(
                  color: event.isCompleted
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: event.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
            if (event.isCompleted)
              Icon(Icons.check_circle_rounded,
                  color: _typeColor, size: 16),
          ],
        ),
      );
}
