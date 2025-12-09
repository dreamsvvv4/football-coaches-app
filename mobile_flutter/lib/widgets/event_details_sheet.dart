import 'package:flutter/material.dart';
import '../screens/match_detail_screen.dart';
import '../services/agenda_service.dart';
import '../utils/event_style.dart';
import '../utils/time_format.dart';
import '../theme/app_theme.dart';
import 'premium_widgets.dart';

class EventDetailsSheet extends StatelessWidget {
  final AgendaItem item;
  final VoidCallback? onViewMore;
  const EventDetailsSheet({super.key, required this.item, this.onViewMore});

  @override
  Widget build(BuildContext context) {
    final color = EventStyle.colorFor(item);
    final icon = EventStyle.iconFor(item);
    final time = TimeFormat.hourMinute(context, item.when);
    final date = TimeFormat.compactDate(item.when);

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text('$date · $time', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: ActionButton(
                  label: item.matchId != null ? 'Ir al detalle' : 'Ver más',
                  onPressed: () {
                    Navigator.pop(context);
                    if (item.matchId != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MatchDetailScreen(matchId: item.matchId!),
                        ),
                      );
                    } else {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(AppTheme.spaceLg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color.withValues(alpha: 0.12),
                                    ),
                                    child: Icon(icon, color: color),
                                  ),
                                  const SizedBox(width: AppTheme.spaceMd),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 4),
                                        Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spaceMd),
                              Row(
                                children: [
                                  Icon(Icons.schedule, size: 16, color: AppTheme.textSecondary),
                                  const SizedBox(width: 6),
                                  Text('$date · $time', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spaceMd),
                              if (item.subtitle.isNotEmpty)
                                Text('Notas: ${item.subtitle}', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: AppTheme.spaceLg),
                              Center(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  isFullWidth: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),
        ],
      ),
    );
  }
}
