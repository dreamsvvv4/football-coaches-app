import 'package:flutter/material.dart';
import 'match_detail_screen.dart';
import 'upcoming_feature_screen.dart';
import '../widgets/calendar_view.dart';
import '../theme/app_theme.dart';
import '../services/agenda_service.dart';
import '../utils/event_style.dart';
import '../utils/time_range.dart';
import '../widgets/event_details_sheet.dart';
import '../widgets/premium_empty_state.dart';
import '../services/auth_service.dart';
import '../services/permission_service.dart';
import 'event_creation_screen.dart';
import '../utils/time_format.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Future<List<AgendaItem>> _futureAgenda;

  @override
  void initState() {
    super.initState();
    _futureAgenda = AgendaService.instance.getUpcoming();
  }

  void _reloadAgenda() {
    setState(() {
      _futureAgenda = AgendaService.instance.getUpcoming();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: FutureBuilder<List<AgendaItem>>( 
        future: _futureAgenda,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Center(
                child: Text('Error al cargar calendario', style: Theme.of(context).textTheme.bodyMedium),
              ),
            );
          }
          final agendaItems = snapshot.data ?? [];
          final range = TimeRange.getRelevantRange();
          final start = range['start']!;
          final end = range['end']!;
          final filtered = agendaItems.where((it) => it.when.isAfter(start) && it.when.isBefore(end)).toList();
          filtered.sort((a, b) => a.when.compareTo(b.when));
          final events = filtered.map((it) => _mapAgendaToCalendarEvent(it)).toList();
          final content = <Widget>[
            CalendarWithEvents(
              events: events,
              onDaySelected: (date) {
                final dayEvents = events
                    .where((e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day)
                    .toList()
                  ..sort((a, b) => a.date.compareTo(b.date));

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius2xl)),
                  ),
                  builder: (_) {
                    final headerText = '${TimeFormat.weekdayShort(date).toUpperCase()} ${date.day} · ${TimeFormat.monthName(date)}';
                    return Padding(
                      padding: const EdgeInsets.all(AppTheme.spaceLg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sticky header (remains visible) + optional create CTA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                headerText,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              if (PermissionService.canRecordMatch(AuthService.instance.activeContext))
                                TextButton.icon(
                                  onPressed: () async {
                                    final created = await Navigator.of(context).push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => const EventCreationScreen(),
                                      ),
                                    );
                                    if (created == true) {
                                      _reloadAgenda();
                                    }
                                  },
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Crear evento'),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spaceMd),
                          if (dayEvents.isEmpty)
                            PremiumEmptyState(
                              onCreate: PermissionService.canRecordMatch(AuthService.instance.activeContext)
                                  ? () async {
                                      final created = await Navigator.of(context).push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => const EventCreationScreen(),
                                        ),
                                      );
                                      if (created == true) {
                                        _reloadAgenda();
                                      }
                                    }
                                  : null,
                            )
                          else
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: dayEvents.length,
                                itemBuilder: (context, index) {
                                  final ev = dayEvents[index];
                                  final item = AgendaItem(
                                    title: ev.title,
                                    subtitle: ev.description ?? '',
                                    icon: ev.icon ?? Icons.event,
                                    when: ev.date,
                                    matchId: null,
                                    routeName: null,
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
                                    child: EventDetailsSheet(
                                      item: item,
                                      onViewMore: () {
                                        if (item.matchId != null) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => MatchDetailScreen(matchId: item.matchId!),
                                            ),
                                          );
                                        } else {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => const UpcomingFeatureScreen(),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
              onEventTap: (event) {
                   final item = AgendaItem(
                    title: event.title,
                    subtitle: event.description ?? '',
                    icon: event.icon ?? Icons.event,
                    when: event.date,
                    matchId: null,
                    routeName: null,
                  );
                   showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius2xl)),
                    ),
                    builder: (_) => EventDetailsSheet(
                      item: item,
                      onViewMore: () {
                        if (item.matchId != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MatchDetailScreen(matchId: item.matchId!),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const UpcomingFeatureScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              'Próximos eventos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            if (filtered.isEmpty)
              Text(
                'No hay eventos próximos en el rango actual.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              )
            else
              ...filtered.take(6).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: EventStyle.colorFor(item).withValues(alpha: 0.12),
                        child: Icon(EventStyle.iconFor(item), color: EventStyle.colorFor(item)),
                      ),
                      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius2xl)),
                          ),
                          builder: (_) => EventDetailsSheet(
                            item: item,
                            onViewMore: () {
                              if (item.matchId != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MatchDetailScreen(matchId: item.matchId!),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const UpcomingFeatureScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
          ];

          if (events.isEmpty) {
            content.add(
              const SizedBox(height: AppTheme.spaceLg),
            );
            content.add(
              PremiumEmptyState(
                onCreate: PermissionService.canRecordMatch(AuthService.instance.activeContext)
                    ? () async {
                        final created = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const EventCreationScreen(),
                          ),
                        );
                        if (created == true) {
                          _reloadAgenda();
                        }
                      }
                    : null,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            children: content,
          );
        },
      ),
    );
  }

  CalendarEvent _mapAgendaToCalendarEvent(AgendaItem it) {
    // Preserve styles: color by type, icon from AgendaItem when available
    final color = EventStyle.colorFor(it);
    final icon = EventStyle.iconFor(it);

    return CalendarEvent(
      id: it.matchId ?? it.title,
      title: it.title,
      date: it.when,
      description: it.subtitle,
      color: color,
      icon: it.icon ?? icon,
      isMatch: it.matchId != null,
    );
  }
}
