import 'package:flutter/material.dart';
import '../services/agenda_service.dart';
import '../theme/app_theme.dart';

class EventStyle {
  static Color colorFor(AgendaItem it) {
    final t = it.title.toLowerCase();
    if (it.matchId != null || t.contains('vs')) return AppTheme.info; // Matches → premium blue set
    if (t.contains('entrenamiento')) return AppTheme.primaryGreen; // Trainings
    if (t.contains('anuncio') || t.contains('announcement')) return AppTheme.warning; // Soft yellow
    if (t.contains('reunión') || t.contains('meeting')) return const Color(0xFF6A5ACD);
    if (t.contains('torneo')) return AppTheme.accentOrange;
    return AppTheme.textSecondary;
  }

  static IconData iconFor(AgendaItem it) {
    final t = it.title.toLowerCase();
    if (it.matchId != null || t.contains('vs')) return Icons.sports_soccer;
    if (t.contains('entrenamiento')) return Icons.fitness_center;
    if (t.contains('anuncio') || t.contains('announcement')) return Icons.campaign;
    if (t.contains('reunión') || t.contains('meeting')) return Icons.meeting_room;
    if (t.contains('torneo')) return Icons.emoji_events;
    return Icons.event;
  }
}
