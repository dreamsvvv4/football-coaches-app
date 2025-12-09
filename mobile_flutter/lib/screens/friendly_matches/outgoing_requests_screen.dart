import 'package:flutter/material.dart';
import '../../../models/friendly_match_request.dart';
import '../../../services/friendly_match_service_premium.dart';

class OutgoingRequestsScreen extends StatelessWidget {
  const OutgoingRequestsScreen({super.key});

  Color _statusColor(FriendlyMatchRequestStatus status, ThemeData theme) {
    switch (status) {
      case FriendlyMatchRequestStatus.pending:
        return Colors.amber;
      case FriendlyMatchRequestStatus.accepted:
        return Colors.green;
      case FriendlyMatchRequestStatus.rejected:
        return Colors.redAccent;
      case FriendlyMatchRequestStatus.modified:
        return theme.colorScheme.secondary;
    }
  }

  String _statusLabel(FriendlyMatchRequestStatus status) {
    switch (status) {
      case FriendlyMatchRequestStatus.pending:
        return 'Pendiente';
      case FriendlyMatchRequestStatus.accepted:
        return 'Aceptado';
      case FriendlyMatchRequestStatus.rejected:
        return 'Rechazado';
      case FriendlyMatchRequestStatus.modified:
        return 'Modificado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // TODO: obtener teamId real del usuario
    const teamId = 'myTeamId';
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes enviadas')),
      body: StreamBuilder<List<FriendlyMatchRequest>>(
        stream: FriendlyMatchService.instance.getOutgoingRequests(teamId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return Center(child: Text('No hay solicitudes enviadas', style: theme.textTheme.bodyLarge));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final req = requests[i];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: theme.colorScheme.surface.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sports_soccer, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Text('Equipo rival: ', style: theme.textTheme.bodyMedium),
                          Text(req.toTeamId, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _statusColor(req.status, theme).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _statusColor(req.status, theme), width: 1.2),
                            ),
                            child: Text(_statusLabel(req.status), style: theme.textTheme.bodySmall?.copyWith(color: _statusColor(req.status, theme), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: theme.colorScheme.secondary),
                          const SizedBox(width: 6),
                          Text('Fecha: ${req.proposedDate.day}/${req.proposedDate.month}/${req.proposedDate.year}', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.place, size: 18, color: theme.colorScheme.secondary),
                          const SizedBox(width: 6),
                          Text('Lugar: ${req.proposedLocation}', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      if (req.notes != null && req.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.note, size: 18, color: theme.colorScheme.secondary),
                            const SizedBox(width: 6),
                            Expanded(child: Text(req.notes!, style: theme.textTheme.bodySmall)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
