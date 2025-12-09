import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'event_details_sheet.dart';
import '../services/agenda_service.dart';

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final String? description;
  final Color? color;
  final IconData? icon;
  final bool isMatch;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    this.color,
    this.icon,
    this.isMatch = false,
  });
}

class CalendarView extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;
  final List<CalendarEvent> events;

  const CalendarView({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.events = const [],
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _FifaCalendarBackground extends StatelessWidget {
  const _FifaCalendarBackground();
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.heroGradient,
        ),
      ),
    );
  }
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _FifaCalendarBackground(),
        Column(
          children: [
            _buildHeader(),
            const SizedBox(height: AppTheme.spaceMd),
            _buildWeekDays(),
            const SizedBox(height: AppTheme.spaceSm),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _buildCalendarGrid(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final months = const [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_left, color: Colors.white),
            ),
          ),
          Text(
            '${months[_currentMonth.month - 1]} ${_currentMonth.year}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    final theme = Theme.of(context);
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    final int firstWeekday = firstDayOfMonth.weekday; // Monday=1
    final List<Widget> dayWidgets = [];

    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final eventsOnDay = _getEventsForDate(date);
      final hasMatch = eventsOnDay.any((e) => e.isMatch);
      final matchColor = hasMatch ? (eventsOnDay.firstWhere((e) => e.isMatch).color) : null;
      final nonMatch = eventsOnDay.where((e) => !e.isMatch).toList();
      final dotColors = nonMatch.take(3).map((e) => e.color ?? AppTheme.accentOrange).toList();
      final extraCount = nonMatch.length > 3 ? (nonMatch.length - 3) : 0;

      nonMatch.sort((a, b) => a.date.compareTo(b.date));
      final first = nonMatch.isNotEmpty ? nonMatch.first : null;
      final firstColor = first?.color ?? AppTheme.accentOrange;
      final firstIcon = first?.icon ?? Icons.event;
      final firstTitle = first?.title ?? '';
      final firstTime = first != null ? TimeOfDay.fromDateTime(first.date).format(context) : '';
      final moreCount = nonMatch.length > 1 ? (nonMatch.length - 1) : 0;
      final isSelected = _selectedDate != null &&
          date.year == _selectedDate!.year &&
          date.month == _selectedDate!.month &&
          date.day == _selectedDate!.day;
      final isToday = _isToday(date);

      dayWidgets.add(
        _DayCell(
          day: day,
          date: date,
          isSelected: isSelected,
          isToday: isToday,
          hasEvents: eventsOnDay.isNotEmpty,
          eventCount: eventsOnDay.length,
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
            widget.onDateSelected?.call(date);
          },
          hasMatch: hasMatch,
          matchColor: matchColor,
          dotColors: dotColors,
          extraCount: extraCount,
          firstEventColor: firstColor,
          firstEventIcon: firstIcon,
          firstEventTitle: firstTitle,
          firstEventTimeLabel: firstTime,
          moreCount: moreCount,
          nonMatch: nonMatch,
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppTheme.spaceSm,
      crossAxisSpacing: AppTheme.spaceSm,
      children: dayWidgets,
    );
  }

  List<CalendarEvent> _getEventsForDate(DateTime date) {
    return widget.events.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool hasEvents;
  final int eventCount;
  final VoidCallback onTap;
  final bool hasMatch;
  final Color? matchColor;
  final List<Color> dotColors;
  final int extraCount;
  final Color firstEventColor;
  final IconData firstEventIcon;
  final String firstEventTitle;
  final String firstEventTimeLabel;
  final int moreCount;
  final List<CalendarEvent> nonMatch;

  const _DayCell({
    required this.day,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.hasEvents,
    required this.eventCount,
    required this.onTap,
    required this.hasMatch,
    required this.matchColor,
    required this.dotColors,
    required this.extraCount,
    required this.firstEventColor,
    required this.firstEventIcon,
    required this.firstEventTitle,
    required this.firstEventTimeLabel,
    required this.moreCount,
    required this.nonMatch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    final baseColor = matchColor ?? AppTheme.primaryGreen;
    final bgColor = hasMatch
      ? baseColor.withValues(alpha: isSelected ? 1.0 : 0.18)
      : isSelected
        ? AppTheme.primaryGreen.withValues(alpha: 0.18)
            : Colors.transparent;
    final border = isToday && !isSelected
        ? Border.all(color: AppTheme.primaryGreen, width: 2)
        : null;

    bool _modalOpen = false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        boxShadow: isSelected ? AppTheme.shadowGlow : [],
      ),
      child: InkWell(
        onTap: () async {
          onTap();
          if (hasEvents && !_modalOpen) {
            _modalOpen = true;
            await showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) {
                final allEvents = [...nonMatch];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Eventos del día', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      ...allEvents.take(3).map((e) => ListTile(
                            leading: Icon(e.icon ?? Icons.event, color: e.color ?? AppTheme.primaryGreen),
                            title: Text(e.title, style: theme.textTheme.bodyMedium),
                            subtitle: Text(TimeOfDay.fromDateTime(e.date).format(context)),
                            onTap: () {
                              Navigator.of(context).pop();
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                builder: (_) => EventDetailsSheet(
                                  item: AgendaItem(
                                    title: e.title,
                                    subtitle: e.description ?? '',
                                    icon: e.icon ?? Icons.event,
                                    when: e.date,
                                    matchId: null,
                                    routeName: null,
                                  ),
                                ),
                              );
                            },
                          )),
                      if (allEvents.length > 3)
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Todos los eventos'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: allEvents.map((e) => ListTile(
                                      leading: Icon(e.icon ?? Icons.event, color: e.color ?? AppTheme.primaryGreen),
                                      title: Text(e.title, style: theme.textTheme.bodyMedium),
                                      subtitle: Text(TimeOfDay.fromDateTime(e.date).format(context)),
                                    )).toList(),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: const Text('Ver más'),
                        ),
                    ],
                  ),
                );
              },
            );
            _modalOpen = false;
          }
        },
        child: Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : isPast
                                ? AppTheme.textTertiary
                                : AppTheme.textPrimary,
                        fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (hasEvents)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(firstEventIcon, size: 13, color: firstEventColor),
                            if (eventCount > 1)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.only(left: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.accentGradient,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: firstEventColor.withOpacity(0.18),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$eventCount',
                                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalendarWithEvents extends StatelessWidget {
  final List<CalendarEvent> events;
  final Function(CalendarEvent)? onEventTap;
  final Function(DateTime)? onDaySelected;

  const CalendarWithEvents({
    super.key,
    required this.events,
    this.onEventTap,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDate;

    return StatefulBuilder(
      builder: (context, setState) {
        final selectedEvents = selectedDate != null
            ? events.where((e) =>
                e.date.year == selectedDate!.year &&
                e.date.month == selectedDate!.month &&
                e.date.day == selectedDate!.day).toList()
            : [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalendarView(
              events: events,
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                });
                if (onDaySelected != null) {
                  onDaySelected!(date);
                }
              },
            ),
            if (selectedEvents.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spaceXl),
              Text(
                'Eventos del día',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              ...selectedEvents.map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
                  child: _EventCard(
                    event: event,
                    onTap: onEventTap != null ? () => onEventTap!(event) : null,
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback? onTap;

  const _EventCard({
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventColor = event.color ?? AppTheme.primaryGreen;

    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: eventColor.withValues(alpha: 0.3)),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: eventColor.withValues(alpha: 0.15),
              ),
              child: Icon(
                event.icon ?? Icons.event,
                color: eventColor,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (event.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    TimeOfDay.fromDateTime(event.date).format(context),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: eventColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
