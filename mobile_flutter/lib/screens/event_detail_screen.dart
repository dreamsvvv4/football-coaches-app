import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/agenda_service.dart';
import '../services/auth_service.dart';
import '../services/club_event_service.dart';

class EventDetailScreen extends StatelessWidget {
  final AgendaItem event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final String lugar = event.subtitle.contains('Campo') ? event.subtitle : 'Campo Principal';
    final String equipo = 'Juvenil A';
    final String tipo = 'Entrenamiento';
    final String notas = 'Traer agua y equipación completa.';

    final user = AuthService.instance.currentUser;
    final clubEvent = null; // TODO: fetch real ClubEvent
    final List<String> asistentes = clubEvent != null
        ? ClubEventService.instance.getAttendees(clubEvent)
        : ['Juan', 'Pedro', 'Luis', 'Carlos'];
    bool rsvp = clubEvent != null && user != null
        ? clubEvent.attendees.contains(user.id)
        : false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(event.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceXl),
            child: ListView(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(event.icon, color: AppTheme.primaryGreen, size: 32),
                    ),
                    const SizedBox(width: AppTheme.spaceLg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(tipo, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.info)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceXl),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Text('${event.when.day}/${event.when.month}/${event.when.year}  ${event.when.hour.toString().padLeft(2, '0')}:${event.when.minute.toString().padLeft(2, '0')}', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Text(lugar, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  children: [
                    const Icon(Icons.group, size: 18, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Text(equipo, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Text('Notas:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(notas, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppTheme.spaceMd),
                Text('Asistentes:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                Wrap(
                  spacing: 8,
                  children: asistentes.map((a) => Chip(label: Text(a))).toList(),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: rsvp || user == null || clubEvent == null
                          ? null
                          : () {
                              ClubEventService.instance.rsvpToEvent(clubEvent, user.id);
                              setState(() {
                                rsvp = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Asistencia confirmada')),);
                            },
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(rsvp ? 'Asistencia confirmada' : 'Confirmar asistencia'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notificación enviada al equipo')),);
                      },
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Notificar equipo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
