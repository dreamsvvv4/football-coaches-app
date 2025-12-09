import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/agenda_service.dart';
import '../event_detail_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Hub'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderBranding(),
              const SizedBox(height: AppTheme.spaceXl),
              _KpiRow(),
              const SizedBox(height: AppTheme.spaceXl),
              _UpcomingEventsRow(),
              const SizedBox(height: AppTheme.spaceXl),
              _QuickActionsGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBranding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceXl),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowLg,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(Icons.shield, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: AppTheme.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mi Club', style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Academia U12', style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _KpiCard(icon: Icons.sports_soccer, label: 'Próximo partido', value: 'Sáb 18:00')),
        SizedBox(width: AppTheme.spaceLg),
        Expanded(child: _KpiCard(icon: Icons.fitness_center, label: 'Entrenamiento', value: 'Jue 17:00')),
        SizedBox(width: AppTheme.spaceLg),
        Expanded(child: _KpiCard(icon: Icons.notifications, label: 'No leídas', value: '3')),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _KpiCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppTheme.primaryGreen.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: theme.textTheme.labelMedium!.copyWith(color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _UpcomingEventsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Próximos eventos', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppTheme.spaceMd),
        SizedBox(
          height: 96,
          child: FutureBuilder<List<AgendaItem>>(
            future: AgendaService.instance.getUpcoming(),
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spaceMd),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _EventPill(item: item);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EventPill extends StatelessWidget {
  final AgendaItem item;
  const _EventPill({required this.item});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: item),
          ),
        );
      },
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppTheme.secondaryTeal.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(item.icon, color: AppTheme.secondaryTeal),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppTheme.textSecondary)),
          ])),
        ]),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(icon: Icons.add_box, label: 'Crear evento', route: '/event_creator'),
      _QuickAction(icon: Icons.groups, label: 'Convocar jugadores', route: '/callups'),
      _QuickAction(icon: Icons.fitness_center, label: 'Entrenamientos', route: '/training_rules'),
      _QuickAction(icon: Icons.campaign, label: 'Anuncios', route: '/announcements'),
      _QuickAction(icon: Icons.chat, label: 'Chat del equipo', route: '/team_chat'),
    ];
    final isWeb = Theme.of(context).platform == TargetPlatform.fuchsia ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux ||
        Theme.of(context).platform == TargetPlatform.macOS;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: actions.map((action) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _QuickActionCircle(action: action),
        )).toList(),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String? route;
  const _QuickAction({required this.icon, required this.label, this.route});
}


class _QuickActionCircle extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionCircle({required this.action});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () {
            if (action.route != null) {
              Navigator.of(context).pushNamed(action.route!);
            }
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(action.icon, color: AppTheme.primaryGreen, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: Text(
            action.label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
