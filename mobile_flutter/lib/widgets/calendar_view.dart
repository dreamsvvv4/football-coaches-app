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
    // Keep the background extremely subtle. On web/desktop the previous
    // gradient reduced contrast and made day labels hard to read.
    final colors = AppTheme.heroGradient.colors
        .map((c) => c.withValues(alpha: 0.06))
        .toList(growable: false);
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AppTheme.heroGradient.begin,
              end: AppTheme.heroGradient.end,
              colors: colors,
            ),
          ),
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
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        const _FifaCalendarBackground(),
        Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
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
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final months = const [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Icon(Icons.chevron_left, color: scheme.onSurface),
            ),
          ),
          Text(
            '${months[_currentMonth.month - 1]} ${_currentMonth.year}',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Icon(Icons.chevron_right, color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
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

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: AppTheme.spaceSm,
        crossAxisSpacing: AppTheme.spaceSm,
        mainAxisExtent: 56,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dayWidgets.length,
      itemBuilder: (context, index) => dayWidgets[index],
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
    final scheme = theme.colorScheme;
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

    final Color dayTextColor;
    if (isSelected) {
      dayTextColor = scheme.onPrimary;
    } else if (isPast) {
      dayTextColor = scheme.onSurfaceVariant.withValues(alpha: 0.65);
    } else {
      dayTextColor = scheme.onSurface;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        boxShadow: isSelected ? AppTheme.shadowGlow : [],
      ),
      child: InkWell(
        onTap: onTap,
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
                        color: dayTextColor,
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
    return CalendarView(
      events: events,
      onDateSelected: (date) {
        if (onDaySelected != null) {
          onDaySelected!(date);
        }
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEvent event;

  const _EventCard({
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventColor = event.color ?? AppTheme.primaryGreen;

    return InkWell(
      // onTap parameter removed as it was unused
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
