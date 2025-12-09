import 'dart:async';

import 'package:flutter/material.dart';
import '../services/match_service.dart';
import '../services/auth_service.dart';
import '../services/realtime_service.dart';

String _statusLabel(String status) {
  switch (status) {
    case 'scheduled':
      return 'Programado';
    case 'live':
      return 'En juego';
    case 'finished':
      return 'Finalizado';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'live':
      return Colors.orangeAccent.shade100;
    case 'finished':
      return Colors.blueGrey.shade100;
    default:
      return Colors.greenAccent.shade100;
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'live':
      return Icons.flash_on;
    case 'finished':
      return Icons.flag;
    default:
      return Icons.schedule;
  }
}

class MatchDetailScreen extends StatefulWidget {
  final String matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  MatchDetail? _detail;
  bool _loading = true;
  String? _error;
  StreamSubscription<MatchDetail>? _subscription;
  StreamSubscription<RealtimeEvent>? _realtimeSubscription;
  // ignore: unused_field
  bool _realtimeConnected = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
    _subscribeToRealtimeUpdates();
  }

  void _subscribe() {
    _subscription = MatchService.instance.watchMatch(widget.matchId).listen(
      (detail) {
        if (!mounted) return;
        setState(() {
          _detail = detail;
          _loading = false;
          _error = null;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _error = 'No se pudo cargar el partido';
          _loading = false;
        });
      },
    );
  }

  /// Subscribe to real-time events for this match
  void _subscribeToRealtimeUpdates() {
    _realtimeSubscription = RealtimeService.instance.subscribeToMatch(widget.matchId).listen(
      (event) {
        if (!mounted) return;
        _handleRealtimeEvent(event);
      },
      onError: (e) {
        if (!mounted) return;
        if (mounted) {
          setState(() => _realtimeConnected = false);
        }
      },
      onDone: () {
        if (!mounted) return;
        if (mounted) {
          setState(() => _realtimeConnected = false);
        }
      },
    );

    // Update connection status
    if (mounted) {
      setState(() => _realtimeConnected = RealtimeService.instance.isConnected);
    }
  }

  /// Process incoming real-time event and update UI
  void _handleRealtimeEvent(RealtimeEvent event) {
    if (_detail == null) return;

    final detail = _detail!;

    // Convert realtime event to MatchEvent for display
    final matchEvent = MatchEvent(
      minute: event.minute != null ? "${event.minute}'" : 'xx',
      type: event.type,
      description: event.description ?? 'Evento desconocido',
      team: event.team,
      player: event.player,
      recordedById: event.recordedById,
      recordedByName: event.recordedByName,
      recordedAt: event.timestamp,
    );

    // Update match state based on event type
    var updatedDetail = detail;
    switch (event.type) {
      case 'goal':
        // Increment score based on which team scored
        final newHome = event.team == 'home' ? detail.homeScore + 1 : detail.homeScore;
        final newAway = event.team == 'away' ? detail.awayScore + 1 : detail.awayScore;
        updatedDetail = detail.copyWith(
          homeScore: newHome,
          awayScore: newAway,
          timeline: [...detail.timeline, matchEvent],
        );
        break;

      case 'yellow_card':
      case 'red_card':
      case 'sub':
        // Just add to timeline
        updatedDetail = detail.copyWith(
          timeline: [...detail.timeline, matchEvent],
        );
        break;

      case 'match_status':
        // Update match status (e.g., started, paused, finished)
        final newStatus = event.data['status'] as String? ?? detail.status;
        updatedDetail = detail.copyWith(
          status: newStatus,
          timeline: [...detail.timeline, matchEvent],
        );
        break;

      case 'score_update':
        // Update score directly
        final newHome = event.data['homeScore'] as int? ?? detail.homeScore;
        final newAway = event.data['awayScore'] as int? ?? detail.awayScore;
        updatedDetail = detail.copyWith(
          homeScore: newHome,
          awayScore: newAway,
          timeline: [...detail.timeline, matchEvent],
        );
        break;

      default:
        // Unknown event type, just add to timeline
        updatedDetail = detail.copyWith(
          timeline: [...detail.timeline, matchEvent],
        );
    }

    // Update UI with animated transition
    if (!mounted) return;
    setState(() {
      _detail = updatedDetail;
      _realtimeConnected = RealtimeService.instance.isConnected;
    });

    // Show notification for important events
    if (['goal', 'red_card', 'match_status'].contains(event.type)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(event.description ?? 'Evento en directo'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _refresh() async {
    setState(() => _error = null);
    try {
      await MatchService.instance.fetchMatch(widget.matchId);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo actualizar el partido';
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _realtimeSubscription?.cancel();
    RealtimeService.instance.unsubscribeFromMatch(widget.matchId);
    super.dispose();
  }

  bool get _canEditTimeline {
    final role = AuthService.instance.currentUser?.role ?? 'coach';
    final perms = AuthService.instance.getActionPermsForRole(role);
    return perms.contains('match_live_events');
  }

  Future<void> _addEvent() async {
    final detail = _detail;
    if (detail == null) return;
    final controllerMinute = TextEditingController();
    final controllerPlayer = TextEditingController();
    String eventType = 'goal';
    String team = 'home';
    final success = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registrar incidencia', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: eventType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'goal', child: Text('Gol')),
                  DropdownMenuItem(value: 'yellow_card', child: Text('Tarjeta amarilla')),
                  DropdownMenuItem(value: 'red_card', child: Text('Tarjeta roja')),
                  DropdownMenuItem(value: 'sub', child: Text('Cambio')),
                ],
                onChanged: (v) => eventType = v ?? eventType,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: team,
                decoration: const InputDecoration(labelText: 'Equipo'),
                items: [
                  DropdownMenuItem(value: 'home', child: Text(detail.homeTeam)),
                  DropdownMenuItem(value: 'away', child: Text(detail.awayTeam)),
                ],
                onChanged: (v) => team = v ?? team,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controllerMinute,
                decoration: const InputDecoration(labelText: 'Minuto (ej. 72)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controllerPlayer,
                decoration: const InputDecoration(labelText: 'Jugador implicado'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (controllerMinute.text.trim().isEmpty) {
                          controllerMinute.text = '0';
                        }
                        Navigator.pop(context, true);
                      },
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (success != true) return;
    final minuteText = controllerMinute.text.trim();
    final minute = minuteText.isEmpty ? "0'" : "$minuteText'";
    final player = controllerPlayer.text.trim();
    final description = _buildDescription(eventType, player.isEmpty ? null : player, team == 'home' ? detail.homeTeam : detail.awayTeam);
    final user = AuthService.instance.currentUser;
    MatchService.instance.addEvent(
      detail.id,
      MatchEvent(
        minute: minute,
        type: eventType,
        description: description,
        team: team,
        player: player.isEmpty ? null : player,
        recordedById: user?.id,
        recordedByName: user?.name,
        recordedAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incidencia registrada')));
  }

  Future<void> _finishMatch() async {
    final detail = _detail;
    if (detail == null || detail.status == 'finished') return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar partido'),
        content: const Text('¿Confirmas que el partido ha finalizado? Esto bloqueará nuevas incidencias.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    final user = AuthService.instance.currentUser;
    MatchService.instance.endMatch(
      detail.id,
      closingEvent: MatchEvent(
        minute: 'FT',
        type: 'match_end',
        description: 'Final del partido',
        team: 'home',
        recordedById: user?.id,
        recordedByName: user?.name,
        recordedAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partido marcado como finalizado')));
  }

  String _buildDescription(String type, String? player, String teamName) {
    final who = player ?? 'Jugador';
    switch (type) {
      case 'goal':
        return '$who marca para $teamName';
      case 'yellow_card':
        return '$who recibe amarilla';
      case 'red_card':
        return '$who es expulsado';
      case 'sub':
        return '$who participa en un cambio';
      default:
        return '$who en $teamName';
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del partido')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _refresh, child: const Text('Reintentar')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _MatchHeader(detail: detail!),
                      const SizedBox(height: 16),
                      _ScoreBoard(detail: detail),
                      const SizedBox(height: 16),
                      _Lineups(detail: detail),
                      const SizedBox(height: 16),
                      _Timeline(
                        detail: detail,
                        canAddEvent: _canEditTimeline && detail.status != 'finished',
                        canFinish: _canEditTimeline && detail.status != 'finished',
                        onAddEvent: _addEvent,
                        onFinish: _finishMatch,
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _MatchHeader extends StatelessWidget {
  final MatchDetail detail;
  const _MatchHeader({required this.detail});

  @override
  Widget build(BuildContext context) {
    final date = '${detail.kickoff.day}/${detail.kickoff.month}/${detail.kickoff.year} · ${TimeOfDay.fromDateTime(detail.kickoff).format(context)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(detail.competition, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(date, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 20),
            const SizedBox(width: 4),
            Text(detail.venue),
          ],
        ),
        const SizedBox(height: 8),
        Chip(
          label: Text(_statusLabel(detail.status)),
          avatar: Icon(_statusIcon(detail.status), size: 18),
        ),
      ],
    );
  }
}

class _ScoreBoard extends StatelessWidget {
  final MatchDetail detail;
  const _ScoreBoard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final scoreText = '${detail.homeScore} - ${detail.awayScore}';
    final statusLabel = _statusLabel(detail.status);
    final statusColor = _statusColor(detail.status);
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Chip(
                label: Text(statusLabel),
                backgroundColor: statusColor,
                labelStyle: const TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 8),
            Text('Marcador actual', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(detail.homeTeam, style: Theme.of(context).textTheme.titleLarge),
            Text(scoreText, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text(detail.awayTeam, style: Theme.of(context).textTheme.titleLarge),
            if (detail.status == 'finished') ...[
              const SizedBox(height: 12),
              Text('Partido finalizado', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _Lineups extends StatelessWidget {
  final MatchDetail detail;
  const _Lineups({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alineaciones', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: detail.homeLineup.map((p) => Text(p)).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: detail.awayLineup.map((p) => Text(p)).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final MatchDetail detail;
  final bool canAddEvent;
  final bool canFinish;
  final VoidCallback onAddEvent;
  final VoidCallback? onFinish;
  const _Timeline({
    required this.detail,
    required this.canAddEvent,
    required this.canFinish,
    required this.onAddEvent,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cronología', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (detail.timeline.isEmpty)
              Text('Aún no hay incidencias', style: Theme.of(context).textTheme.bodySmall)
            else
              ...detail.timeline.map(
                (ev) => ListTile(
                  leading: _eventIcon(ev.type),
                  title: Text(ev.description),
                  subtitle: (ev.player != null || ev.recordedByName != null)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (ev.player != null) Text(ev.player!),
                            if (ev.recordedByName != null)
                              Text(
                                'Registrado por ${ev.recordedByName}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        )
                      : null,
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(ev.minute),
                      if (ev.recordedAt != null)
                        Text(
                          _relativeTime(ev.recordedAt!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
            if (canAddEvent || canFinish) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (canAddEvent)
                    FilledButton.icon(
                      onPressed: onAddEvent,
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir evento'),
                    ),
                  if (canFinish && onFinish != null)
                    OutlinedButton.icon(
                      onPressed: onFinish,
                      icon: const Icon(Icons.flag),
                      label: const Text('Finalizar partido'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Solo visible para roles con permiso de incidencias en directo.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _eventIcon(String type) {
    switch (type) {
      case 'goal':
        return const Icon(Icons.sports_soccer, color: Colors.green);
      case 'yellow_card':
        return const Icon(Icons.square_foot, color: Colors.amber);
      case 'red_card':
        return const Icon(Icons.report, color: Colors.redAccent);
      case 'sub':
        return const Icon(Icons.swap_horiz, color: Colors.blueAccent);
      case 'match_end':
        return const Icon(Icons.flag, color: Colors.black87);
      default:
        return const Icon(Icons.info_outline);
    }
  }

  String _relativeTime(DateTime recordedAt) {
    final now = DateTime.now();
    final diff = now.difference(recordedAt);
    if (diff.inHours >= 1) {
      final hours = diff.inHours;
      return hours == 1 ? 'hace 1 h' : 'hace ${hours} h';
    }
    if (diff.inMinutes >= 1) {
      final mins = diff.inMinutes;
      return mins == 1 ? 'hace 1 min' : 'hace ${mins} min';
    }
    final seconds = diff.inSeconds.clamp(0, 59);
    return seconds <= 1 ? 'hace instantes' : 'hace ${seconds}s';
  }
}
