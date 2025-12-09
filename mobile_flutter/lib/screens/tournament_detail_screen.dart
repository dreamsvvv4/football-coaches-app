import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TournamentStatus { draft, active, completed, cancelled }
enum TournamentType { roundRobin, knockout, mixed }
enum FootballMode { football11, football7, futsal }
enum MatchStatus { scheduled, inProgress, paused, completed, cancelled, postponed }

class TournamentDetailScreen extends StatefulWidget {
  final dynamic tournament;
  final dynamic tournamentService;
  const TournamentDetailScreen({Key? key, required this.tournament, required this.tournamentService}) : super(key: key);

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {

    void _loadTournamentData() {
      // TODO: Implementar lógica de recarga si es necesario
    }
  dynamic get tournament => widget.tournament;

  @override
  Widget build(BuildContext context) {
    // Example UI, adapt as needed
    return Scaffold(
      appBar: AppBar(title: Text(tournament?.name ?? 'Torneo')),
      floatingActionButton: _buildFAB(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection('Información'),
            _buildInfoRow('Tipo', _getTournamentTypeName(tournament?.type ?? TournamentType.roundRobin)),
            _buildInfoRow('Modo', _getFootballModeName(tournament?.mode ?? FootballMode.football11)),
            _buildInfoRow('Estado', _getStatusBadge(tournament?.status ?? TournamentStatus.draft)),
            const SizedBox(height: 24),
            _buildInfoSection('Reglas'),
            _buildRuleRow('Regla 1', true),
            _buildRuleRow('Regla 2', false),
            // ...
          ],
        ),
      ),
    );
  }
// Removed duplicate/legacy code after build method

  Widget _buildInfoSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          if (value is Widget)
            value
          else
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String rule, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rule),
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.green : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    if (tournament.status == TournamentStatus.draft) {
      return FloatingActionButton.extended(
        onPressed: () {
          final activated = widget.tournamentService.activateTournament(
            tournament.id,
          );
          if (activated != null) {
            _loadTournamentData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tournament activated!')),
            );
          }
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Activate'),
      );
    }
    return const SizedBox.shrink();
  }

  // Helper methods
  String _getTournamentTypeName(TournamentType type) {
    switch (type) {
      case TournamentType.roundRobin:
        return 'Round Robin';
      case TournamentType.knockout:
        return 'Knockout';
      case TournamentType.mixed:
        return 'Mixed (Groups + Knockout)';
    }
  }

  String _getFootballModeName(FootballMode mode) {
    switch (mode) {
      case FootballMode.football11:
        return 'Football 11';
      case FootballMode.football7:
        return 'Football 7';
      case FootballMode.futsal:
        return 'Futsal';
    }
  }

  Widget _getStatusBadge(TournamentStatus status) {
    final color = _getStatusColorForBadge(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColorForBadge(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.draft:
        return Colors.grey;
      case TournamentStatus.active:
        return Colors.green;
      case TournamentStatus.completed:
        return Colors.blue;
      case TournamentStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatDateHeader(DateTime date) {
    return DateFormat('EEEE, MMM d').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _getStatusText(MatchStatus status) {
    switch (status) {
      case MatchStatus.scheduled:
        return 'Scheduled';
      case MatchStatus.inProgress:
        return 'Live';
      case MatchStatus.paused:
        return 'Paused';
      case MatchStatus.completed:
        return 'Completed';
      case MatchStatus.cancelled:
        return 'Cancelled';
      case MatchStatus.postponed:
        return 'Postponed';
    }
  }

  Color _getMatchStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.scheduled:
        return Colors.blue;
      case MatchStatus.inProgress:
        return Colors.red;
      case MatchStatus.paused:
        return Colors.orange;
      case MatchStatus.completed:
        return Colors.green;
      case MatchStatus.cancelled:
        return Colors.grey;
      case MatchStatus.postponed:
        return Colors.orange;
    }
  }
}
