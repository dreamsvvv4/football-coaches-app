import 'package:flutter/material.dart';
import '../../../models/friendly_match_request.dart';
import '../../../services/friendly_match_service_premium.dart';

class IncomingRequestsScreen extends StatelessWidget {
  const IncomingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // TODO: obtener teamId real del usuario
    const teamId = 'myTeamId';
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes recibidas')),
      body: StreamBuilder<List<FriendlyMatchRequest>>(
        stream: FriendlyMatchService.instance.getIncomingRequests(teamId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return Center(child: Text('No hay solicitudes recibidas', style: theme.textTheme.bodyLarge));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final req = requests[i];
              return Card(
                elevation: 3,
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
                          Text('Equipo solicitante: ', style: theme.textTheme.bodyMedium),
                          Text(req.fromTeamId, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              await FriendlyMatchService.instance.rejectRequest(req.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud rechazada')));
                            },
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                            child: const Text('Rechazar'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              // Navegar a pantalla de proponer nueva fecha
                              Navigator.pushNamed(context, '/friendly_matches/request_edit', arguments: req);
                            },
                            style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.secondary),
                            child: const Text('Proponer cambios'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              await FriendlyMatchService.instance.acceptRequest(req.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud aceptada')));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
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
