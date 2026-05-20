import 'package:flutter/material.dart';

class AppColors {
  // ── Base palette ──────────────────────────────────────────────
  static const Color background   = Color(0xFF0A0A0F);
  static const Color surface      = Color(0xFF13131A);
  static const Color surfaceHigh  = Color(0xFF1C1C27);
  static const Color border       = Color(0xFF2A2A3A);
  static const Color divider      = Color(0xFF1E1E2E);

  static const Color textPrimary   = Color(0xFFF1F1F8);
  static const Color textSecondary = Color(0xFF8B8BA7);
  static const Color textMuted     = Color(0xFF5A5A7A);

  // ── Global accent ─────────────────────────────────────────────
  static const Color accent       = Color(0xFF6366F1); // Indigo
  static const Color accentLight  = Color(0xFF818CF8);
  static const Color accentDim    = Color(0xFF3730A3);

  // ── Dashboard (Royal Blue → Indigo) ───────────────────────────
  static const Color dashboardStart = Color(0xFF3B82F6);
  static const Color dashboardEnd   = Color(0xFF6366F1);
  static const LinearGradient dashboardGradient = LinearGradient(
    colors: [dashboardStart, dashboardEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Tasks (Teal → Cyan) ───────────────────────────────────────
  static const Color tasksStart = Color(0xFF06B6D4);
  static const Color tasksEnd   = Color(0xFF0891B2);
  static const LinearGradient tasksGradient = LinearGradient(
    colors: [tasksStart, tasksEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Habits (Emerald → Green) ──────────────────────────────────
  static const Color habitsStart = Color(0xFF10B981);
  static const Color habitsEnd   = Color(0xFF059669);
  static const LinearGradient habitsGradient = LinearGradient(
    colors: [habitsStart, habitsEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Calendar (Magenta → Purple) ───────────────────────────────
  static const Color calendarStart = Color(0xFFEC4899);
  static const Color calendarEnd   = Color(0xFF9333EA);
  static const LinearGradient calendarGradient = LinearGradient(
    colors: [calendarStart, calendarEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Notes (Amber → Rose Gold) ─────────────────────────────────
  static const Color notesStart = Color(0xFFF59E0B);
  static const Color notesEnd   = Color(0xFFEF4444);
  static const LinearGradient notesGradient = LinearGradient(
    colors: [notesStart, notesEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Mood (Coral → Peach) ──────────────────────────────────────
  static const Color moodStart = Color(0xFFF97316);
  static const Color moodEnd   = Color(0xFFFBBF24);
  static const LinearGradient moodGradient = LinearGradient(
    colors: [moodStart, moodEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Finance (Forest Green → Lime) ────────────────────────────
  static const Color financeStart = Color(0xFF22C55E);
  static const Color financeEnd   = Color(0xFF84CC16);
  static const LinearGradient financeGradient = LinearGradient(
    colors: [financeStart, financeEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Priority colours ──────────────────────────────────────────
  static const Color priorityHigh   = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow    = Color(0xFF10B981);

  // ── Note card tints ───────────────────────────────────────────
  static const List<Color> noteColors = [
    Color(0xFF1E293B),
    Color(0xFF1C1B2E),
    Color(0xFF1B2336),
    Color(0xFF1E1B2E),
    Color(0xFF1F1F1F),
    Color(0xFF1C2B1E),
  ];

  // ── Glassmorphism helpers ─────────────────────────────────────
  static Color glassWhite(double opacity) => Colors.white.withOpacity(opacity);
  static Color glassBlack(double opacity) => Colors.black.withOpacity(opacity);
}
