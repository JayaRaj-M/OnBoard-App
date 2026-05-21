import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../features/tasks/providers/task_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../tasks/presentation/tasks_screen.dart';
import '../../habits/presentation/habits_screen.dart';
import '../../calendar/presentation/calendar_screen.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../mood/presentation/mood_screen.dart';
import '../../finance/presentation/finance_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _pages = <Widget>[
    _DashboardOverview(),
    TasksScreen(),
    HabitsScreen(),
    CalendarScreen(),
    NotesScreen(),
    MoodScreen(),
    FinanceScreen(),
  ];

  static const _navItems = [
    
    _NavItem(icon: Icons.dashboard_rounded,        label: AppStrings.navDashboard),
    _NavItem(icon: Icons.check_circle_outline_rounded, label: AppStrings.navTasks),
    _NavItem(icon: Icons.repeat_rounded,           label: AppStrings.navHabits),
    _NavItem(icon: Icons.calendar_month_rounded,   label: AppStrings.navCalendar),
    _NavItem(icon: Icons.sticky_note_2_rounded,    label: AppStrings.navNotes),
    _NavItem(icon: Icons.mood_rounded,             label: AppStrings.navMood),
    _NavItem(icon: Icons.account_balance_wallet_rounded, label: AppStrings.navFinance),
  ];

  static const _gradients = [
    AppColors.dashboardGradient,
    AppColors.tasksGradient,
    AppColors.habitsGradient,
    AppColors.calendarGradient,
    AppColors.notesGradient,
    AppColors.moodGradient,
    AppColors.financeGradient,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(dashboardIndexProvider);
    final isWide =
        MediaQuery.of(context).size.width >= AppSizes.tabletBreakpoint;

    if (isWide) {
      return _WideLayout(
        index: index,
        pages: _pages,
        navItems: _navItems,
        gradients: _gradients,
        onTap: (i) => ref.read(dashboardIndexProvider.notifier).set(i),
      );
    }

    return _NarrowLayout(
      index: index,
      pages: _pages,
      navItems: _navItems,
      gradients: _gradients,
      onTap: (i) => ref.read(dashboardIndexProvider.notifier).set(i),
    );
  }
}

// ── Navigation data class ─────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ── Wide (tablet/desktop) ─────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final int index;
  final List<Widget> pages;
  final List<_NavItem> navItems;
  final List<LinearGradient> gradients;
  final ValueChanged<int> onTap;

  const _WideLayout({
    required this.index,
    required this.pages,
    required this.navItems,
    required this.gradients,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _Sidebar(
            index: index,
            navItems: navItems,
            gradients: gradients,
            onTap: onTap,
          ),
          const VerticalDivider(
              color: AppColors.border, width: 1, thickness: 1),
          Expanded(child: pages[index]),
        ],
      ),
    );
  }
}

// ── Narrow (mobile) ───────────────────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  final int index;
  final List<Widget> pages;
  final List<_NavItem> navItems;
  final List<LinearGradient> gradients;
  final ValueChanged<int> onTap;

  const _NarrowLayout({
    required this.index,
    required this.pages,
    required this.navItems,
    required this.gradients,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: _BottomNav(
        index: index,
        navItems: navItems,
        gradients: gradients,
        onTap: onTap,
      ),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final int index;
  final List<_NavItem> navItems;
  final List<LinearGradient> gradients;
  final ValueChanged<int> onTap;

  const _Sidebar({
    required this.index,
    required this.navItems,
    required this.gradients,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.sidebarWidth,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.dashboardGradient.createShader(b),
                  child: const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const Text(
                  AppStrings.appTagline,
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          ...List.generate(navItems.length, (i) {
            final item = navItems[i];
            final isActive = i == index;
            return _SidebarItem(
              item: item,
              gradient: gradients[i],
              isActive: isActive,
              onTap: () => onTap(i),
            );
          }),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Text(
              'v1.0.0',
              style:
                  TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final LinearGradient gradient;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.gradient,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppSizes.animFast,
        margin: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: 3),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive ? gradient.scale(0.2) : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: isActive
              ? Border.all(
                  color: gradient.colors.first.withOpacity(0.4),
                  width: 1)
              : null,
        ),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (b) => (isActive ? gradient : const LinearGradient(colors: [AppColors.textMuted, AppColors.textMuted])).createShader(b),
              child: Icon(item.icon,
                  color: Colors.white,
                  size: AppSizes.sidebarIconSize),
            ),
            const SizedBox(width: AppSizes.md),
            Text(
              item.label,
              style: TextStyle(
                color: isActive
                    ? gradient.colors.first
                    : AppColors.textSecondary,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int index;
  final List<_NavItem> navItems;
  final List<LinearGradient> gradients;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.index,
    required this.navItems,
    required this.gradients,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.navBarHeight + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        children: List.generate(navItems.length, (i) {
          final item = navItems[i];
          final isActive = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: AppSizes.animFast,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? gradients[i].scale(0.25)
                          : null,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: ShaderMask(
                      shaderCallback: (b) => (isActive ? gradients[i] : const LinearGradient(colors: [AppColors.textMuted, AppColors.textMuted])).createShader(b),
                      child: Icon(item.icon,
                          color: Colors.white,
                          size: AppSizes.iconMd),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isActive
                          ? gradients[i].colors.first
                          : AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Dashboard Overview Page ───────────────────────────────────────
class _DashboardOverview extends ConsumerWidget {
  const _DashboardOverview();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.lg, AppSizes.xl, AppSizes.lg, AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting ────────────────────────────────────────
          Text(
            '${_greeting()}, ${AppStrings.userName} 👋',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormatter.fullDate(DateTime.now()),
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: AppSizes.xl),

          // ── Stats grid ──────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSizes.md,
            crossAxisSpacing: AppSizes.md,
            childAspectRatio: 1.6,
            children: [
              _StatCard(
                label: 'Tasks Pending',
                value: '${stats.pendingTasks}',
                icon: Icons.check_circle_outline_rounded,
                gradient: AppColors.tasksGradient,
              ),
              _StatCard(
                label: 'Habits Done',
                value: '${stats.habitsCompletedToday}/${stats.totalHabits}',
                icon: Icons.repeat_rounded,
                gradient: AppColors.habitsGradient,
              ),
              _StatCard(
                label: 'Balance',
                value: DateFormatter.currency(stats.balance),
                icon: Icons.account_balance_wallet_rounded,
                gradient: AppColors.financeGradient,
              ),
              _StatCard(
                label: "Today's Mood",
                value: stats.todayMoodEmoji ?? 'Not logged',
                icon: Icons.mood_rounded,
                gradient: AppColors.moodGradient,
                isEmoji: stats.todayMoodEmoji != null,
              ),
            ],
          ),

          const SizedBox(height: AppSizes.xl),

          // ── Quick access ─────────────────────────────────────
          const Text(
            'Quick Access',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _QuickAccessGrid(ref: ref),

          const SizedBox(height: AppSizes.xl),

          // ── Upcoming tasks ───────────────────────────────────
          const Text(
            'Upcoming Tasks',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _UpcomingTasks(ref: ref),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final bool isEmoji;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    this.isEmoji = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: gradient.colors.first.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: gradient.scale(0.25),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(icon,
                      color: gradient.colors.first, size: 16),
                ),
                const Spacer(),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: isEmoji
                  ? const TextStyle(fontSize: 28)
                  : const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      );
}

class _QuickAccessGrid extends StatelessWidget {
  final WidgetRef ref;
  const _QuickAccessGrid({required this.ref});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Tasks', Icons.check_circle_outline_rounded, AppColors.tasksGradient, 1),
      ('Habits', Icons.repeat_rounded, AppColors.habitsGradient, 2),
      ('Notes', Icons.sticky_note_2_rounded, AppColors.notesGradient, 4),
      ('Finance', Icons.account_balance_wallet_rounded, AppColors.financeGradient, 6),
    ];

    return Row(
      children: items.map((item) {
        final (label, icon, gradient, pageIdx) = item;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              ref.read(dashboardIndexProvider.notifier).set(pageIdx);
            },
            child: Container(
              margin: const EdgeInsets.only(right: AppSizes.sm),
              padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.md, horizontal: AppSizes.sm),
              decoration: BoxDecoration(
                gradient: gradient.scale(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(
                    color: gradient.colors.first.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (b) => gradient.createShader(b),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: gradient.colors.first,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _UpcomingTasks extends ConsumerWidget {
  final WidgetRef ref;
  const _UpcomingTasks({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref
        .watch(taskProvider)
        .where((t) => !t.isCompleted)
        .take(5)
        .toList();

    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'No pending tasks 🎉',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tasks.length,
        separatorBuilder: (_, __) =>
            const Divider(color: AppColors.border, height: 1),
        itemBuilder: (ctx, i) {
          final task = tasks[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: 4),
            leading: GestureDetector(
              onTap: () =>
                  ref.read(taskProvider.notifier).toggleComplete(task.id),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.tasksStart, width: 2),
                ),
              ),
            ),
            title: Text(
              task.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: task.dueDate != null
                ? Text(
                    DateFormatter.relativeDay(task.dueDate!),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  )
                : null,
          );
        },
      ),
    );
  }
}
