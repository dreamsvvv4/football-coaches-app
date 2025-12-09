import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/form_widgets.dart';

/// Tournament Creation Screen - Full form to create tournaments
class TournamentCreationScreen extends StatefulWidget {
  const TournamentCreationScreen({Key? key}) : super(key: key);

  @override
  State<TournamentCreationScreen> createState() =>
      _TournamentCreationScreenState();
}

class _TournamentCreationScreenState extends State<TournamentCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TournamentService _tournamentService;

  // Form fields
  String _name = '';
  String _description = '';
  TournamentType _type = TournamentType.roundRobin;
  FootballMode _mode = FootballMode.football11;
  PlayerCategory _category = PlayerCategory.amateur;
  int _matchDuration = 90;
  late DateTime _startDate;
  String _venueId = '';
  String _venueName = 'Select Venue';
  String _venueLat = '';
  String _venueLng = '';
  bool _allowExtraTime = true;
  bool _allowPenalties = true;
  bool _useVAR = false;
  int _maxSubstitutions = 3;

  final List<String> _selectedTeamIds = [];
  final List<String> _selectedTeamNames = [];

  // Mock data
  final List<Map<String, String>> _venues = [
    {'id': 'v1', 'name': 'Central Park', 'lat': '40.7850', 'lng': '-73.9735'},
    {'id': 'v2', 'name': 'Stadium A', 'lat': '40.7282', 'lng': '-74.0076'},
    {'id': 'v3', 'name': 'Municipal Ground', 'lat': '40.7489', 'lng': '-73.9680'},
  ];

  final List<Map<String, String>> _availableTeams = [
    {'id': 't1', 'name': 'Manchester United'},
    {'id': 't2', 'name': 'Liverpool FC'},
    {'id': 't3', 'name': 'Chelsea FC'},
    {'id': 't4', 'name': 'Arsenal FC'},
    {'id': 't5', 'name': 'Tottenham Hotspur'},
    {'id': 't6', 'name': 'Manchester City'},
    {'id': 't7', 'name': 'Brighton & Hove'},
    {'id': 't8', 'name': 'Aston Villa'},
  ];

  @override
  void initState() {
    super.initState();
    _tournamentService = TournamentService();
    _startDate = DateTime.now().add(const Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tournament'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 12),
              PremiumTextField(
                label: 'Tournament Name',
                hint: 'e.g. Summer Championship',
                prefixIcon: Icons.sports_soccer,
                onChanged: (value) => setState(() => _name = value),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Tournament name is required'
                    : null,
              ),
              const SizedBox(height: 12),
              PremiumTextField(
                label: 'Description',
                hint: 'Details about the tournament',
                prefixIcon: Icons.description,
                maxLines: 3,
                onChanged: (value) => setState(() => _description = value),
              ),
              const SizedBox(height: 20),

              // Tournament Configuration Section
              _buildSectionTitle('Tournament Configuration'),
              const SizedBox(height: 12),

              // Tournament Type
              _buildEnumSelector<TournamentType>(
                label: 'Tournament Type',
                currentValue: _type,
                items: TournamentType.values,
                getLabel: (type) {
                  switch (type) {
                    case TournamentType.roundRobin:
                      return 'Round Robin (League)';
                    case TournamentType.knockout:
                      return 'Knockout (Bracket)';
                    case TournamentType.mixed:
                      return 'Mixed (Groups + Knockout)';
                  }
                },
                onChanged: (value) => setState(() => _type = value),
              ),
              const SizedBox(height: 12),

              // Football Mode
              _buildEnumSelector<FootballMode>(
                label: 'Football Mode',
                currentValue: _mode,
                items: FootballMode.values,
                getLabel: (mode) {
                  switch (mode) {
                    case FootballMode.football11:
                      return 'Football 11 (Full)';
                    case FootballMode.football7:
                      return 'Football 7 (Mini)';
                    case FootballMode.futsal:
                      return 'Futsal (Indoor)';
                  }
                },
                onChanged: (value) => setState(() => _mode = value),
              ),
              const SizedBox(height: 12),

              // Player Category
              _buildEnumSelector<PlayerCategory>(
                label: 'Player Category',
                currentValue: _category,
                items: PlayerCategory.values,
                getLabel: (cat) => cat.name[0].toUpperCase() + cat.name.substring(1),
                onChanged: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: 12),

              // Match Duration
              PremiumTextField(
                label: 'Match Duration (minutes)',
                hint: '90',
                prefixIcon: Icons.schedule,
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    setState(() => _matchDuration = int.tryParse(value) ?? 90),
                validator: (value) {
                  final num = int.tryParse(value ?? '');
                  if (num == null || num < 30 || num > 120) {
                    return 'Duration must be between 30 and 120 minutes';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Venue Selection Section
              _buildSectionTitle('Venue Selection'),
              const SizedBox(height: 12),
              _buildVenueSelector(),
              const SizedBox(height: 20),

              // Team Selection Section
              _buildSectionTitle('Team Selection'),
              const SizedBox(height: 12),
              _buildTeamSelector(),
              const SizedBox(height: 20),

              // Tournament Rules Section
              _buildSectionTitle('Tournament Rules'),
              const SizedBox(height: 12),
              _buildRulesCheckboxes(),
              const SizedBox(height: 20),

              // Start Date Section
              _buildSectionTitle('Start Date'),
              const SizedBox(height: 12),
              _buildDateSelector(),
              const SizedBox(height: 30),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ActionButton(
                  onPressed: _createTournament,
                  label: 'Create Tournament',
                  icon: Icons.check_circle,
                  isFullWidth: true,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildEnumSelector<T extends Enum>({
    required String label,
    required T currentValue,
    required List<T> items,
    required String Function(T) getLabel,
    required void Function(T) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items.map((item) {
              final isSelected = item == currentValue;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(getLabel(item)),
                  onSelected: (_) => onChanged(item),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVenueSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          isExpanded: true,
          value: _venueId.isEmpty ? null : _venueId,
          hint: Text(_venueName),
          items: _venues.map((venue) {
            return DropdownMenuItem(
              value: venue['id']!,
              child: Text(venue['name']!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              final venue = _venues.firstWhere((v) => v['id'] == value);
              setState(() {
                _venueId = venue['id']!;
                _venueName = venue['name']!;
                _venueLat = venue['lat']!;
                _venueLng = venue['lng']!;
              });
            }
          },
        ),
        if (_venueName != 'Select Venue')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Coordinates: $_venueLat, $_venueLng',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildTeamSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Teams (${_selectedTeamIds.length})',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTeams.map((team) {
            final isSelected =
                _selectedTeamIds.contains(team['id']);
            return FilterChip(
              selected: isSelected,
              label: Text(team['name']!),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTeamIds.add(team['id']!);
                    _selectedTeamNames.add(team['name']!);
                  } else {
                    _selectedTeamIds.remove(team['id']);
                    _selectedTeamNames.remove(team['name']);
                  }
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              ),
            );
          }).toList(),
        ),
        if (_selectedTeamIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least 2 teams',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildRulesCheckboxes() {
    return Column(
      children: [
        _buildCheckbox(
          'Allow Extra Time',
          _allowExtraTime,
          (value) => setState(() => _allowExtraTime = value),
        ),
        _buildCheckbox(
          'Allow Penalties',
          _allowPenalties,
          (value) => setState(() => _allowPenalties = value),
        ),
        _buildCheckbox(
          'Use VAR',
          _useVAR,
          (value) => setState(() => _useVAR = value),
        ),
        const SizedBox(height: 12),
        PremiumTextField(
          label: 'Max Substitutions',
          hint: '3',
          prefixIcon: Icons.swap_horiz,
          keyboardType: TextInputType.number,
          onChanged: (value) =>
              setState(() => _maxSubstitutions = int.tryParse(value) ?? 3),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, void Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (newValue) => onChanged(newValue ?? false),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Date',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  _formatDate(_startDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Icon(Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix validation errors')),
      );
      return;
    }

    if (_selectedTeamIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 2 teams')),
      );
      return;
    }

    if (_venueId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a venue')),
      );
      return;
    }

    try {
      final tournament = _tournamentService.createTournament(
        name: _name,
        description: _description,
        type: _type,
        mode: _mode,
        category: _category,
        matchDuration: _matchDuration,
        venueId: _venueId,
        venueName: _venueName,
        venueLat: _venueLat,
        venueLng: _venueLng,
        teamIds: _selectedTeamIds,
        teamNames: _selectedTeamNames,
        startDate: _startDate,
        createdBy: 'coach_001', // Mock user ID
        rules: TournamentRules(
          allowExtraTime: _allowExtraTime,
          allowPenalties: _allowPenalties,
          minPlayersRequired:
              _mode == FootballMode.football11 ? 11 : (_mode == FootballMode.football7 ? 7 : 5),
          maxSubstitutions: _maxSubstitutions,
          maxCardWarnings: 2,
          useVAR: _useVAR,
        ),
      );

      // Generate fixtures
      _tournamentService.generateFixtures(
        tournamentId: tournament.id,
        startDate: _startDate,
        venueId: _venueId,
        venueName: _venueName,
        matchDuration: _matchDuration,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tournament "${tournament.name}" created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back or to detail screen
        Navigator.pop(context, tournament);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating tournament: $e')),
      );
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tournament Types'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Round Robin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('All teams play each other once'),
              SizedBox(height: 12),
              Text(
                'Knockout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Elimination bracket style'),
              SizedBox(height: 12),
              Text(
                'Mixed',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Group stage followed by knockout'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
