import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/mock_auth_service.dart';
// import '../services/permission_service.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  bool _loading = true;
  String _statusFilter = 'all';
  List<Map<String, dynamic>> _tournaments = [];

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Map<String, dynamic> _normalizeTournament(Map<String, dynamic> raw) {
    List<String> toTeams(dynamic value) {
      if (value is List) {
        return value.whereType<String>().toList();
      }
      return [];
    }

    List<Map<String, dynamic>> toMatches(dynamic value) {
      if (value is List) {
        return value.whereType<Map>().map((match) {
          final copy = Map<String, dynamic>.from(match);
          copy['home'] = copy['home'] ?? copy['local'];
          copy['away'] = copy['away'] ?? copy['visitante'];
          copy['scoreHome'] = copy['scoreHome'] is int
              ? copy['scoreHome']
              : int.tryParse('${copy['scoreHome']}');
          copy['scoreAway'] = copy['scoreAway'] is int
              ? copy['scoreAway']
              : int.tryParse('${copy['scoreAway']}');
          copy['status'] = (copy['status'] as String?) ?? 'Programado';
          copy['matchday'] = copy['matchday'] ?? copy['jornada'];
          copy['date'] = copy['date'] ?? 'Por definir';
          return copy;
        }).toList();
      }
      return [];
    }

    List<Map<String, dynamic>> toStandings(dynamic value) {
      if (value is List) {
        return value.whereType<Map>().map((row) {
          final copy = Map<String, dynamic>.from(row);
          return {
            'team': copy['team'] ?? copy['nombre'] ?? '',
            'played': copy['played'] ?? copy['pj'] ?? 0,
            'wins': copy['wins'] ?? copy['pg'] ?? 0,
            'draws': copy['draws'] ?? copy['pe'] ?? 0,
            'losses': copy['losses'] ?? copy['pp'] ?? 0,
            'gf': copy['gf'] ?? copy['golesFavor'] ?? 0,
            'ga': copy['ga'] ?? copy['golesContra'] ?? 0,
            'gd': copy['gd'] ??
                copy['diferencia'] ??
                ((copy['gf'] ?? 0) - (copy['ga'] ?? 0)),
            'pts': copy['pts'] ?? copy['puntos'] ?? 0,
          };
        }).toList();
      }
      return [];
    }

    List<List<Map<String, dynamic>>> toBracket(dynamic value) {
      if (value is List) {
        if (value.isNotEmpty && value.first is Map) {
          final firstMap = value.first as Map;
          if (!firstMap.containsKey('round')) {
            final legacy = value.whereType<Map>().map((match) {
              final copy = Map<String, dynamic>.from(match);
              return <String, dynamic>{
                'round': 1,
                'matchIndex': 0,
                'home': copy['home'] ?? copy['a'],
                'away': copy['away'] ?? copy['b'],
                'scoreHome': copy['scoreHome'] is int
                    ? copy['scoreHome']
                    : int.tryParse('${copy['scoreHome']}'),
                'scoreAway': copy['scoreAway'] is int
                    ? copy['scoreAway']
                    : int.tryParse('${copy['scoreAway']}'),
                'status': copy['status'] ?? 'Programado',
                'winner': copy['winner'],
              };
            }).toList();
            return [legacy];
          }
        }
        return value
            .whereType<List>()
            .map((round) => round
                .whereType<Map>()
                .map((match) => Map<String, dynamic>.from(match))
                .toList())
            .toList();
      }
      return [];
    }

    Map<String, dynamic> toStats(dynamic value) {
      if (value is Map<String, dynamic>) {
        return {
          'played': value['played'] ?? 0,
          'goals': value['goals'] ?? 0,
          'averageGoals': value['averageGoals'] ?? 0.0,
          'topAttack': value['topAttack'],
          'bestDefense': value['bestDefense'],
        };
      }
      return {
        'played': 0,
        'goals': 0,
        'averageGoals': 0.0,
        'topAttack': null,
        'bestDefense': null,
      };
    }

    final normalized = <String, dynamic>{
      'id': raw['id'] ?? 'tournament_${DateTime.now().millisecondsSinceEpoch}',
      'name': raw['name'] ?? 'Torneo sin nombre',
      'type': raw['type'] ?? 'Liga',
      'status': ((raw['status'] as String?) ?? 'draft').toLowerCase(),
      'teams': toTeams(raw['teams']),
      'matches': toMatches(raw['matches']),
      'standings': toStandings(raw['standings']),
      'bracket': toBracket(raw['bracket']),
      'champion': raw['champion'],
      'mvp': raw['mvp'],
      'stats': toStats(raw['stats']),
    };

    _ensureStandingsForTeams(normalized);
    if ((normalized['matches'] as List).isNotEmpty) {
      _recalculateStandings(normalized);
    }
    _recalculateStats(normalized);

    return normalized;
  }

  void _ensureStandingsForTeams(Map<String, dynamic> tournament) {
    final teams = List<String>.from(tournament['teams'] as List? ?? []);
    final rows = (tournament['standings'] as List?)
            ?.whereType<Map>()
            .map((row) {
              final copy = Map<String, dynamic>.from(row);
              final team = copy['team'] as String? ?? '';
              return MapEntry(team, <String, dynamic>{
                'team': team,
                'played': copy['played'] ?? 0,
                'wins': copy['wins'] ?? 0,
                'draws': copy['draws'] ?? 0,
                'losses': copy['losses'] ?? 0,
                'gf': copy['gf'] ?? 0,
                'ga': copy['ga'] ?? 0,
                'gd': copy['gd'] ?? ((copy['gf'] ?? 0) - (copy['ga'] ?? 0)),
                'pts': copy['pts'] ?? 0,
              });
            })
            .where((entry) => entry.key.isNotEmpty)
            .toList() ??
        <MapEntry<String, Map<String, dynamic>>>[];

    final standingsByTeam = <String, Map<String, dynamic>>{
      for (final entry in rows) entry.key: entry.value
    };

    for (final team in teams) {
      standingsByTeam.putIfAbsent(
          team,
          () => {
                'team': team,
                'played': 0,
                'wins': 0,
                'draws': 0,
                'losses': 0,
                'gf': 0,
                'ga': 0,
                'gd': 0,
                'pts': 0,
              });
    }

    tournament['standings'] = teams
        .map((team) =>
            standingsByTeam[team] ??
            {
              'team': team,
              'played': 0,
              'wins': 0,
              'draws': 0,
              'losses': 0,
              'gf': 0,
              'ga': 0,
              'gd': 0,
              'pts': 0,
            })
        .toList();
  }

  void _recalculateStandings(Map<String, dynamic> tournament) {
    _ensureStandingsForTeams(tournament);
    final standings = <String, Map<String, dynamic>>{
      for (final row in (tournament['standings'] as List).whereType<Map>())
        if (row['team'] is String)
          row['team'] as String: {
            'team': row['team'],
            'played': 0,
            'wins': 0,
            'draws': 0,
            'losses': 0,
            'gf': 0,
            'ga': 0,
            'gd': 0,
            'pts': 0,
          }
    };

    List<Map<String, dynamic>> parseMatches(dynamic value) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map((match) => Map<String, dynamic>.from(match))
            .toList();
      }
      return const [];
    }

    final matches = parseMatches(tournament['matches']);
    final bracket = _cloneBracket(tournament['bracket']);
    for (final round in bracket) {
      matches.addAll(round);
    }

    for (final match in matches) {
      final home = match['home'] as String?;
      final away = match['away'] as String?;
      final shRaw = match['scoreHome'];
      final saRaw = match['scoreAway'];
      if (home == null || away == null || shRaw == null || saRaw == null)
        continue;
      final sh = shRaw is int ? shRaw : int.tryParse('$shRaw');
      final sa = saRaw is int ? saRaw : int.tryParse('$saRaw');
      if (sh == null || sa == null) continue;

      final homeRow = standings[home];
      final awayRow = standings[away];
      if (homeRow == null || awayRow == null) continue;

      homeRow['played'] = (homeRow['played'] as int) + 1;
      awayRow['played'] = (awayRow['played'] as int) + 1;
      homeRow['gf'] = (homeRow['gf'] as int) + sh;
      homeRow['ga'] = (homeRow['ga'] as int) + sa;
      awayRow['gf'] = (awayRow['gf'] as int) + sa;
      awayRow['ga'] = (awayRow['ga'] as int) + sh;

      if (sh > sa) {
        homeRow['wins'] = (homeRow['wins'] as int) + 1;
        homeRow['pts'] = (homeRow['pts'] as int) + 3;
        awayRow['losses'] = (awayRow['losses'] as int) + 1;
      } else if (sa > sh) {
        awayRow['wins'] = (awayRow['wins'] as int) + 1;
        awayRow['pts'] = (awayRow['pts'] as int) + 3;
        homeRow['losses'] = (homeRow['losses'] as int) + 1;
      } else {
        homeRow['draws'] = (homeRow['draws'] as int) + 1;
        awayRow['draws'] = (awayRow['draws'] as int) + 1;
        homeRow['pts'] = (homeRow['pts'] as int) + 1;
        awayRow['pts'] = (awayRow['pts'] as int) + 1;
      }
    }

    for (final row in standings.values) {
      row['gd'] = (row['gf'] as int) - (row['ga'] as int);
    }

    final ordered = standings.values.toList()
      ..sort((a, b) {
        final pts = (b['pts'] as int).compareTo(a['pts'] as int);
        if (pts != 0) return pts;
        final gd = (b['gd'] as int).compareTo(a['gd'] as int);
        if (gd != 0) return gd;
        final gf = (b['gf'] as int).compareTo(a['gf'] as int);
        if (gf != 0) return gf;
        return (a['team'] as String).compareTo(b['team'] as String);
      });

    tournament['standings'] = ordered;
  }

  void _recalculateStats(Map<String, dynamic> tournament) {
    final matches = <Map<String, dynamic>>[];
    matches.addAll(
        List<Map<String, dynamic>>.from(tournament['matches'] as List? ?? []));
    final bracket = _cloneBracket(tournament['bracket']);
    for (final round in bracket) {
      matches.addAll(round);
    }

    var played = 0;
    var goals = 0;
    for (final match in matches) {
      final shRaw = match['scoreHome'];
      final saRaw = match['scoreAway'];
      if (shRaw == null || saRaw == null) continue;
      final sh = shRaw is int ? shRaw : int.tryParse('$shRaw');
      final sa = saRaw is int ? saRaw : int.tryParse('$saRaw');
      if (sh == null || sa == null) continue;
      played++;
      goals += sh + sa;
    }

    final standings =
        List<Map<String, dynamic>>.from(tournament['standings'] as List? ?? []);
    String? topAttack;
    String? bestDefense;
    if (standings.isNotEmpty) {
      final byGoalsFor = List<Map<String, dynamic>>.from(standings)
        ..sort((a, b) => (b['gf'] as int).compareTo(a['gf'] as int));
      topAttack =
          byGoalsFor.isNotEmpty ? byGoalsFor.first['team'] as String? : null;

      final byGoalsAgainst = List<Map<String, dynamic>>.from(standings)
        ..sort((a, b) => (a['ga'] as int).compareTo(b['ga'] as int));
      bestDefense = byGoalsAgainst.isNotEmpty
          ? byGoalsAgainst.first['team'] as String?
          : null;
    }

    tournament['stats'] = {
      'played': played,
      'goals': goals,
      'averageGoals':
          played == 0 ? 0.0 : double.parse((goals / played).toStringAsFixed(2)),
      'topAttack': topAttack,
      'bestDefense': bestDefense,
    };
  }

  String? _determineChampion(Map<String, dynamic> tournament) {
    final type = (tournament['type'] as String?)?.toLowerCase() ?? 'liga';
    if (type == 'eliminatoria') {
      final bracket = _cloneBracket(tournament['bracket']);
      if (bracket.isEmpty) return null;
      final lastRound = bracket.last;
      if (lastRound.isEmpty) return null;
      final decisive = lastRound.firstWhere(
        (match) => match['status'] != 'BYE',
        orElse: () => lastRound.first,
      );
      final winner = decisive['winner'];
      return winner is String && winner.isNotEmpty ? winner : null;
    }
    final standings =
        List<Map<String, dynamic>>.from(tournament['standings'] as List? ?? []);
    if (standings.isEmpty) {
      return null;
    }
    final candidate = standings.first;
    if ((candidate['team'] as String?)?.isEmpty ?? true) {
      return null;
    }
    return candidate['team'] as String;
  }

  List<Map<String, dynamic>> _createRoundRobinMatches(List<String> teams) {
    if (teams.length < 2) return [];
    final list = List<String>.from(teams);
    const bye = '__BYE__';
    var hasBye = false;
    if (list.length.isOdd) {
      list.add(bye);
      hasBye = true;
    }
    final rounds = list.length - 1;
    final matchesPerRound = list.length ~/ 2;
    final schedule = <Map<String, dynamic>>[];

    for (var round = 0; round < rounds; round++) {
      for (var match = 0; match < matchesPerRound; match++) {
        final home = list[match];
        final away = list[list.length - 1 - match];
        if (home == bye || away == bye) continue;
        schedule.add({
          'home': home,
          'away': away,
          'matchday': round + 1,
          'date': 'Por definir',
          'scoreHome': null,
          'scoreAway': null,
          'status': 'Programado',
        });
      }
      final pivot = list.removeAt(1);
      list.add(pivot);
    }

    if (hasBye) {
      list.remove(bye);
    }

    return schedule;
  }

  List<List<Map<String, dynamic>>> _createKnockoutBracket(List<String> teams) {
    if (teams.length < 2) return [];
    final participants = List<String>.from(teams);
    var slots = 1;
    while (slots < participants.length) {
      slots *= 2;
    }

    final padded = List<String?>.from(participants);
    while (padded.length < slots) {
      padded.add(null);
    }

    final bracket = <List<Map<String, dynamic>>>[];
    final firstRound = <Map<String, dynamic>>[];
    for (var i = 0; i < slots; i += 2) {
      final home = padded[i];
      final away = padded[i + 1];
      final match = <String, dynamic>{
        'round': 1,
        'matchIndex': i ~/ 2,
        'home': home,
        'away': away,
        'scoreHome': null,
        'scoreAway': null,
        'status': (home == null || away == null) ? 'BYE' : 'Programado',
        'winner': null,
      };
      if (home != null && away == null) {
        match['winner'] = home;
      } else if (away != null && home == null) {
        match['winner'] = away;
      }
      firstRound.add(match);
    }
    bracket.add(firstRound);

    final rounds = (math.log(slots) / math.log(2)).toInt();
    for (var round = 2; round <= rounds; round++) {
      final matchesInRound = slots ~/ math.pow(2, round);
      bracket.add(List.generate(matchesInRound, (index) {
        return {
          'round': round,
          'matchIndex': index,
          'home': null,
          'away': null,
          'scoreHome': null,
          'scoreAway': null,
          'status': 'Pendiente',
          'winner': null,
        };
      }));
    }

    _updateBracketAdvancement(bracket);
    return bracket;
  }

  void _updateBracketAdvancement(List<List<Map<String, dynamic>>> bracket) {
    for (var roundIndex = 1; roundIndex < bracket.length; roundIndex++) {
      final previousRound = bracket[roundIndex - 1];
      final currentRound = bracket[roundIndex];
      for (var matchIndex = 0; matchIndex < currentRound.length; matchIndex++) {
        final sourceA = previousRound[matchIndex * 2];
        final sourceB = previousRound[matchIndex * 2 + 1];
        final match = currentRound[matchIndex];
        final home = sourceA['winner'];
        final away = sourceB['winner'];
        match['home'] = home;
        match['away'] = away;
        if (home != null && away != null) {
          if ((match['status'] as String?) == 'Pendiente' ||
              (match['status'] as String?) == 'BYE') {
            match['status'] = 'Programado';
          }
        } else if (home != null || away != null) {
          match['status'] = 'BYE';
          match['winner'] = home ?? away;
        } else {
          match['status'] = 'Pendiente';
          match['winner'] = null;
        }
      }
    }
  }

  List<List<Map<String, dynamic>>> _cloneBracket(dynamic value) {
    if (value is List) {
      return value
          .whereType<List>()
          .map((round) => round
              .whereType<Map>()
              .map((match) => Map<String, dynamic>.from(match))
              .toList())
          .toList();
    }
    return <List<Map<String, dynamic>>>[];
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Programado';
      case 'finished':
        return 'Finalizado';
      case 'draft':
        return 'Borrador';
      default:
        return status;
    }
  }

  Future<void> _loadTournaments() async {
    setState(() => _loading = true);
    try {
      final response = await MockAuthService.getTournaments();
      final data = response['data'];
      final fetched = response['success'] == true && data is List
          ? data
              .whereType<Map>()
              .map(
                  (raw) => _normalizeTournament(Map<String, dynamic>.from(raw)))
              .toList()
          : <Map<String, dynamic>>[];
      if (!mounted) return;
      setState(() {
        _tournaments = fetched;
        _loading = false;
      });
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los torneos: $err')),
      );
      setState(() {
        _tournaments = [];
        _loading = false;
      });
    }
  }

  void _showCreateTournamentDialog() {
    final nameController = TextEditingController();
    String selectedType = 'Liga';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo torneo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre del torneo'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: const InputDecoration(labelText: 'Formato'),
              items: const [
                DropdownMenuItem(
                    value: 'Liga', child: Text('Liga (round-robin)')),
                DropdownMenuItem(
                    value: 'Eliminatoria',
                    child: Text('Eliminatoria (knockout)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedType = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Introduce un nombre para el torneo.')),
                );
                return;
              }
              final created = _normalizeTournament({
                'name': name,
                'type': selectedType,
                'status': 'draft',
              });
              setState(() {
                _tournaments = [created, ..._tournaments];
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Torneo "$name" creado. Añade equipos para comenzar.')),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    ).whenComplete(nameController.dispose);
  }

  void _showTournamentDetails(Map<String, dynamic> tournament) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final mediaQuery = MediaQuery.of(context);
            final canEditTeams = true; // PermissionService.instance.canEditTeam();
            final canManageTournament = true; // PermissionService.instance.canCreateTournament();
            final canRecordMatches = true; // PermissionService.instance.canRecordMatch();

            void addTeam() {
              if (!canEditTeams) return;
              final controller = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Añadir equipo'),
                  content: TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(labelText: 'Nombre del equipo'),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar')),
                    ElevatedButton(
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;
                        setState(() {
                          final teams = List<String>.from(
                              tournament['teams'] as List? ?? []);
                          if (!teams.contains(name)) {
                            teams.add(name);
                            tournament['teams'] = teams;
                            _ensureStandingsForTeams(tournament);
                          }
                        });
                        setSheetState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Añadir'),
                    ),
                  ],
                ),
              ).whenComplete(controller.dispose);
            }

            void generateSchedule() {
              final teams =
                  List<String>.from(tournament['teams'] as List? ?? []);
              if (teams.length < 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Añade al menos dos equipos para generar partidos.')),
                );
                return;
              }
              final type =
                  (tournament['type'] as String?)?.toLowerCase() ?? 'liga';
              setState(() {
                if (type == 'eliminatoria') {
                  final bracket = _createKnockoutBracket(teams);
                  tournament['bracket'] = bracket;
                  tournament['matches'] = <Map<String, dynamic>>[];
                } else {
                  final matches = _createRoundRobinMatches(teams);
                  tournament['matches'] = matches;
                  tournament['bracket'] = <List<Map<String, dynamic>>>[];
                }
                tournament['status'] = 'scheduled';
                _ensureStandingsForTeams(tournament);
                _recalculateStandings(tournament);
                _recalculateStats(tournament);
              });
              setSheetState(() {});
            }

            void reseedBracket() {
              if (!canManageTournament) return;
              final teams =
                  List<String>.from(tournament['teams'] as List? ?? []);
              if (teams.length < 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Necesitas al menos dos equipos para una eliminatoria.')),
                );
                return;
              }
              setState(() {
                final bracket = _createKnockoutBracket(teams);
                tournament['bracket'] = bracket;
                tournament['matches'] = <Map<String, dynamic>>[];
                tournament['status'] = 'scheduled';
                _recalculateStats(tournament);
              });
              setSheetState(() {});
            }

            void editMatch(int index) {
              if (!canRecordMatches) return;
              final matches = List<Map<String, dynamic>>.from(
                  tournament['matches'] as List? ?? []);
              if (index < 0 || index >= matches.length) return;
              final match = Map<String, dynamic>.from(matches[index]);
              final home = match['home'] as String?;
              final away = match['away'] as String?;
              if (home == null || away == null) return;
              final homeCtrl = TextEditingController(
                  text: match['scoreHome']?.toString() ?? '');
              final awayCtrl = TextEditingController(
                  text: match['scoreAway']?.toString() ?? '');
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Editar marcador: $home vs $away'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: homeCtrl,
                        decoration: InputDecoration(labelText: '$home goles'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: awayCtrl,
                        decoration: InputDecoration(labelText: '$away goles'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar')),
                    ElevatedButton(
                      onPressed: () {
                        final sh = int.tryParse(homeCtrl.text);
                        final sa = int.tryParse(awayCtrl.text);
                        if (sh == null || sa == null) return;
                        setState(() {
                          match
                            ..['scoreHome'] = sh
                            ..['scoreAway'] = sa
                            ..['status'] = 'Finalizado';
                          matches[index] = match;
                          tournament['matches'] = matches;
                          _ensureStandingsForTeams(tournament);
                          _recalculateStandings(tournament);
                          _recalculateStats(tournament);
                        });
                        setSheetState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ).whenComplete(() {
                homeCtrl.dispose();
                awayCtrl.dispose();
              });
            }

            void editBracketMatch(int roundIndex, int matchIndex) {
              if (!canRecordMatches) return;
              final bracket = _cloneBracket(tournament['bracket']);
              if (roundIndex < 0 || roundIndex >= bracket.length) return;
              if (matchIndex < 0 || matchIndex >= bracket[roundIndex].length)
                return;
              final match =
                  Map<String, dynamic>.from(bracket[roundIndex][matchIndex]);
              if (match['status'] == 'BYE') return;
              final home = match['home'] as String?;
              final away = match['away'] as String?;
              if (home == null || away == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Este cruce aún no tiene ambos equipos definidos.')),
                );
                return;
              }
              final homeCtrl = TextEditingController(
                  text: match['scoreHome']?.toString() ?? '');
              final awayCtrl = TextEditingController(
                  text: match['scoreAway']?.toString() ?? '');
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                      'Editar eliminatoria: $home vs $away (Ronda ${match['round']})'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: homeCtrl,
                        decoration: InputDecoration(labelText: '$home goles'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: awayCtrl,
                        decoration: InputDecoration(labelText: '$away goles'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar')),
                    ElevatedButton(
                      onPressed: () {
                        final sh = int.tryParse(homeCtrl.text);
                        final sa = int.tryParse(awayCtrl.text);
                        if (sh == null || sa == null) return;
                        setState(() {
                          match
                            ..['scoreHome'] = sh
                            ..['scoreAway'] = sa
                            ..['status'] = 'Finalizado'
                            ..['winner'] =
                                sh == sa ? null : (sh > sa ? home : away);
                          bracket[roundIndex][matchIndex] = match;
                          _updateBracketAdvancement(bracket);
                          tournament['bracket'] = bracket;
                          _recalculateStats(tournament);
                        });
                        setSheetState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ).whenComplete(() {
                homeCtrl.dispose();
                awayCtrl.dispose();
              });
            }

            void finalizeTournament() {
              setState(() {
                _ensureStandingsForTeams(tournament);
                _recalculateStandings(tournament);
                _recalculateStats(tournament);
              });
              final champion = _determineChampion(tournament);
              if (champion == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Completa resultados para definir un campeón.')),
                );
                return;
              }
              final mvp = '$champion · MVP';
              setState(() {
                tournament['champion'] = champion;
                tournament['mvp'] = mvp;
                tournament['status'] = 'finished';
              });
              setSheetState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Torneo finalizado. Campeón: $champion · MVP: $mvp')),
              );
            }

            final scrollPadding =
                EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom + 16);
            final type =
                (tournament['type'] as String?)?.toLowerCase() ?? 'liga';
            final isKnockout = type == 'eliminatoria';

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              maxChildSize: 0.95,
              minChildSize: 0.6,
              builder: (context, controller) {
                return Padding(
                  padding: EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: scrollPadding.bottom),
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tournament['name'] as String,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Tipo: ${tournament['type']} · Estado: ${_statusLabel(tournament['status'] as String)}'),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: canEditTeams ? addTeam : null,
                                  tooltip: 'Añadir equipo',
                                  icon: const Icon(Icons.group_add),
                                ),
                                IconButton(
                                  onPressed: canManageTournament
                                      ? generateSchedule
                                      : null,
                                  tooltip: isKnockout
                                      ? 'Generar cuadro'
                                      : 'Generar calendario',
                                  icon: const Icon(Icons.calendar_month),
                                ),
                                IconButton(
                                  onPressed: isKnockout && canManageTournament
                                      ? reseedBracket
                                      : null,
                                  tooltip: 'Rehacer cuadro',
                                  icon: const Icon(Icons.account_tree),
                                ),
                                IconButton(
                                  onPressed: canManageTournament
                                      ? finalizeTournament
                                      : null,
                                  tooltip: 'Finalizar torneo',
                                  icon: const Icon(Icons.flag),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Equipos',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List<String>.from(
                                  tournament['teams'] as List? ?? [])
                              .map((team) => Chip(label: Text(team)))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final matches = List<Map<String, dynamic>>.from(
                                tournament['matches'] as List? ?? []);
                            if (matches.isEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Partidos',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 4),
                                  Text(isKnockout
                                      ? 'No hay cuadro generado. Usa el botón de calendario para crearlo.'
                                      : 'No hay jornadas generadas. Usa el botón de calendario para crearlas.'),
                                ],
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Partidos',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 4),
                                ...matches.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final match = entry.value;
                                  final matchday = match['matchday'] != null
                                      ? ' · Jornada ${match['matchday']}'
                                      : '';
                                  final subtitle =
                                      'Estado: ${match['status']} · Resultado: ${match['scoreHome'] ?? '-'}-${match['scoreAway'] ?? '-'}$matchday';
                                  return ListTile(
                                    leading: const Icon(Icons.sports_soccer),
                                    title: Text(
                                        '${match['home']} vs ${match['away']}'),
                                    subtitle: Text(subtitle),
                                    trailing: canRecordMatches
                                        ? IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => editMatch(index),
                                          )
                                        : null,
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final standings = List<Map<String, dynamic>>.from(
                                tournament['standings'] as List? ?? []);
                            if (standings.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tabla de clasificación',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 4),
                                ...standings.map((row) => ListTile(
                                      leading: const Icon(Icons.trending_up),
                                      title: Text(row['team'] as String),
                                      subtitle: Text(
                                        'PJ ${row['played']} · Pts ${row['pts']} · GF ${row['gf']} · GA ${row['ga']} · DG ${row['gd']}',
                                      ),
                                    )),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final bracket =
                                _cloneBracket(tournament['bracket']);
                            if (bracket.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Eliminatorias',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 8),
                                for (var roundIndex = 0;
                                    roundIndex < bracket.length;
                                    roundIndex++) ...[
                                  Text('Ronda ${roundIndex + 1}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  ...bracket[roundIndex]
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final idx = entry.key;
                                    final match = entry.value;
                                    final home = match['home'] ?? 'Por definir';
                                    final away = match['away'] ?? 'Por definir';
                                    final editable = match['status'] != 'BYE' &&
                                        match['home'] != null &&
                                        match['away'] != null;
                                    return ListTile(
                                      leading: const Icon(Icons.account_tree),
                                      title: Text('$home vs $away'),
                                      subtitle: Text(
                                        'Estado: ${match['status']} · Resultado: ${match['scoreHome'] ?? '-'}-${match['scoreAway'] ?? '-'} · Ganador: ${match['winner'] ?? '-'}',
                                      ),
                                      trailing: editable && canRecordMatches
                                          ? IconButton(
                                              icon: const Icon(Icons.edit_note),
                                              onPressed: () => editBracketMatch(
                                                  roundIndex, idx),
                                            )
                                          : null,
                                    );
                                  }).toList(),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final stats = (tournament['stats']
                                    as Map<String, dynamic>?) ??
                                <String, dynamic>{};
                            final played = stats['played'] as int? ?? 0;
                            if (played == 0) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Estadísticas',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 4),
                                ListTile(
                                  leading: const Icon(Icons.bar_chart),
                                  title: const Text('Totales'),
                                  subtitle: Text(
                                    'Partidos jugados: ${stats['played']} · Goles: ${stats['goals']} · Media: ${stats['averageGoals']}',
                                  ),
                                ),
                                if (stats['topAttack'] != null)
                                  ListTile(
                                    leading: const Icon(Icons.flash_on),
                                    title: const Text('Mejor ataque'),
                                    subtitle:
                                        Text(stats['topAttack'] as String),
                                  ),
                                if (stats['bestDefense'] != null)
                                  ListTile(
                                    leading: const Icon(Icons.shield),
                                    title: const Text('Mejor defensa'),
                                    subtitle:
                                        Text(stats['bestDefense'] as String),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (tournament['champion'] != null)
                          Text(
                            'Campeón: ${tournament['champion']} · MVP: ${tournament['mvp']}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTournaments = _statusFilter == 'all'
        ? _tournaments
        : _tournaments
            .where(
                (t) => (t['status'] as String?)?.toLowerCase() == _statusFilter)
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Torneos')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : filteredTournaments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text('No hay torneos creados'),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TournamentSummary(
                        tournaments: _tournaments,
                        selectedFilter: _statusFilter,
                        onFilterChanged: (value) {
                          setState(() => _statusFilter = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filteredTournaments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final tournament = filteredTournaments[index];
                            return _TournamentCard(
                              tournament: tournament,
                              onTap: () => _showTournamentDetails(tournament),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: true // PermissionService.instance.canCreateTournament()
          ? FloatingActionButton.extended(
              heroTag: 'tournamentsFab',
              onPressed: _showCreateTournamentDialog,
              icon: const Icon(Icons.add),
              label: const Text('Crear Torneo'),
            )
          : null,
    );
  }
}

class _TournamentSummary extends StatelessWidget {
  final List<Map<String, dynamic>> tournaments;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _TournamentSummary({
    required this.tournaments,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totals = {
      'all': tournaments.length,
      'draft':
          tournaments.where((t) => (t['status'] as String?) == 'draft').length,
      'scheduled': tournaments
          .where((t) => (t['status'] as String?) == 'scheduled')
          .length,
      'finished': tournaments
          .where((t) => (t['status'] as String?) == 'finished')
          .length,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _OverviewChip(
                icon: Icons.emoji_events,
                label: 'Torneos',
                value: '${totals['all']}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OverviewChip(
                icon: Icons.pending_actions,
                label: 'En preparación',
                value: '${totals['draft']}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OverviewChip(
                icon: Icons.live_tv,
                label: 'En juego',
                value: '${totals['scheduled']}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OverviewChip(
                icon: Icons.flag,
                label: 'Finalizados',
                value: '${totals['finished']}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: totals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final key = totals.keys.elementAt(index);
              final selected = selectedFilter == key;
              String label;
              switch (key) {
                case 'all':
                  label = 'Todos';
                  break;
                case 'draft':
                  label = 'Borrador';
                  break;
                case 'scheduled':
                  label = 'En juego';
                  break;
                case 'finished':
                  label = 'Finalizados';
                  break;
                default:
                  label = key;
              }
              return ChoiceChip(
                label: Text('$label (${totals[key]})'),
                selected: selected,
                onSelected: (_) => onFilterChanged(key),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OverviewChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OverviewChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final Map<String, dynamic> tournament;
  final VoidCallback onTap;

  const _TournamentCard({required this.tournament, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final teamsValue = tournament['teams'];
    final matchesValue = tournament['matches'];
    final teams =
        teamsValue is List ? List<String>.from(teamsValue) : <String>[];
    final matches = matchesValue is List
        ? List<Map<String, dynamic>>.from(matchesValue)
        : <Map<String, dynamic>>[];
    final status = tournament['status'] as String? ?? 'draft';

    Map<String, dynamic>? nextMatch;
    for (final match in matches) {
      final statusValue = (match['status'] as String?)?.toLowerCase();
      if (statusValue != 'finalizado' && statusValue != 'finished') {
        nextMatch = match;
        break;
      }
    }

    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withAlpha(90),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tournament['name'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  Chip(label: Text(_statusLabel(status))),
                ],
              ),
              const SizedBox(height: 8),
              Text('Formato: ${tournament['type']} · Equipos: ${teams.length}'),
              if (nextMatch != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                      'Próximo: ${nextMatch['home']} vs ${nextMatch['away']} · ${nextMatch['date']}'),
                ),
              if (tournament['champion'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Último campeón: ${tournament['champion']}'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'scheduled':
        return 'En juego';
      case 'finished':
        return 'Finalizado';
      case 'draft':
        return 'Borrador';
      default:
        return status;
    }
  }
}
