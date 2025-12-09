import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/tournament.dart';

/// Interactive Bracket Widget - FIFA-style tournament bracket visualization
/// Supports Knockout and Mixed tournament visualization
class BracketWidget extends StatefulWidget {
  final List<Match> matches;
  final Tournament tournament;
  final VoidCallback? onMatchTap;
  final Function(Match match, int homeGoals, int awayGoals)? onResultUpdate;

  const BracketWidget({
    Key? key,
    required this.matches,
    required this.tournament,
    this.onMatchTap,
    this.onResultUpdate,
  }) : super(key: key);

  @override
  State<BracketWidget> createState() => _BracketWidgetState();
}

class _BracketWidgetState extends State<BracketWidget> {
  late Map<int, List<Match>> _matchesByRound;
  int? _selectedMatchId;
  int? _editingHomeGoals;
  int? _editingAwayGoals;

  @override
  void initState() {
    super.initState();
    _initializeBracket();
  }

  void _initializeBracket() {
    _matchesByRound = {};

    if (widget.tournament.type == TournamentType.knockout) {
      // Group by round for knockout
      for (final match in widget.matches.where((m) => m.isKnockout)) {
        final round = match.round ?? 1;
        _matchesByRound.putIfAbsent(round, () => []).add(match);
      }
    } else if (widget.tournament.type == TournamentType.mixed) {
      // Group by round, separate knockout from group stage
      for (final match in widget.matches) {
        if (match.isKnockout) {
          final round = match.round ?? 1;
          _matchesByRound.putIfAbsent(round, () => []).add(match);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _matchesByRound.isEmpty
            ? _buildEmptyBracket()
            : _buildBracketTree(),
      ),
    );
  }

  Widget _buildEmptyBracket() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No knockout matches yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBracketTree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tournament Bracket',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _matchesByRound.entries.toList()
              .asMap()
              .entries
              .map((entry) {
                final roundNum = entry.value.key;
                final matches = entry.value.value;
                return _buildRoundColumn(roundNum, matches);
              })
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRoundColumn(int round, List<Match> matches) {
    final roundName = _getRoundName(round, _matchesByRound.length);

    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            roundName,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(matches.length, (index) {
              return Column(
                children: [
                  _buildBracketMatch(matches[index]),
                  if (index < matches.length - 1) const SizedBox(height: 24),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketMatch(Match match) {
    final isSelected = _selectedMatchId == match.id.hashCode;
    final isCompleted = match.isCompleted;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMatchId = isSelected ? null : match.id.hashCode;
          _editingHomeGoals = match.homeTeamGoals;
          _editingAwayGoals = match.awayTeamGoals;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 280,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatMatchTime(match.scheduledTime),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Final',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            // Match Teams
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildTeamRow(
                    match.homeTeamName,
                    match.homeTeamGoals,
                    isHome: true,
                    isCompleted: isCompleted,
                    onGoalsChanged: isSelected && isCompleted
                        ? (goals) =>
                            setState(() => _editingHomeGoals = goals)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  _buildTeamRow(
                    match.awayTeamName,
                    match.awayTeamGoals,
                    isHome: false,
                    isCompleted: isCompleted,
                    onGoalsChanged: isSelected && isCompleted
                        ? (goals) =>
                            setState(() => _editingAwayGoals = goals)
                        : null,
                  ),
                ],
              ),
            ),
            // Match Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${match.venueName} • ${match.duration}min',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Edit Controls (if selected and completed)
            if (isSelected && isCompleted) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _saveResult(match),
                        icon: const Icon(Icons.save, size: 16),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _selectedMatchId = null),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ] else if (!isCompleted)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _getMatchStatusText(match.status),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(match.status),
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow(
    String teamName,
    int? goals,
    {required bool isHome,
    required bool isCompleted,
    void Function(int)? onGoalsChanged}
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            teamName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onGoalsChanged != null && _selectedMatchId != null)
          SizedBox(
            width: 50,
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              controller: TextEditingController(
                text: isHome ? _editingHomeGoals?.toString() : _editingAwayGoals?.toString(),
              ),
              onChanged: (value) => onGoalsChanged(int.tryParse(value) ?? 0),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              goals?.toString() ?? '-',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
      ],
    );
  }

  String _getRoundName(int round, int totalRounds) {
    if (totalRounds == 1) return 'Final';
    if (round == totalRounds) return 'Final';
    if (round == totalRounds - 1) return 'Semi-Final';
    if (round == totalRounds - 2) return 'Quarter-Final';
    return 'Round $round';
  }

  String _formatMatchTime(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getMatchStatusText(MatchStatus status) {
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

  Color _getStatusColor(MatchStatus status) {
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

  void _saveResult(Match match) {
    if (widget.onResultUpdate != null &&
        _editingHomeGoals != null &&
        _editingAwayGoals != null) {
      widget.onResultUpdate!(match, _editingHomeGoals!, _editingAwayGoals!);
      setState(() => _selectedMatchId = null);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Result updated')),
      );
    }
  }
}

/// Bracket Connection Line Widget
class BracketLine extends CustomPainter {
  final Color color;

  BracketLine({this.color = Colors.grey});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    // Draw connecting line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Draw small circles at connection points
    canvas.drawCircle(Offset(0, size.height / 2), 4, paint);
    canvas.drawCircle(Offset(size.width, size.height / 2), 4, paint);
  }

  @override
  bool shouldRepaint(BracketLine oldDelegate) => color != oldDelegate.color;
}
