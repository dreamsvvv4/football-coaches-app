import 'package:flutter/material.dart';
import '../../../models/club.dart';
import '../../../models/team.dart';
import '../../../models/friendly_match_request.dart';
import '../../../services/friendly_match_service_premium.dart';

class FriendlyMatchCreatorScreen extends StatefulWidget {
  const FriendlyMatchCreatorScreen({super.key});

  @override
  State<FriendlyMatchCreatorScreen> createState() => _FriendlyMatchCreatorScreenState();
}

class _FriendlyMatchCreatorScreenState extends State<FriendlyMatchCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  Club? _selectedClub;
  Team? _selectedTeam;
  DateTime? _selectedDate;
  String? _location;
  String? _notes;
  bool _loading = false;

  // TODO: Reemplazar con providers reales
  List<Club> _clubs = [
    Club(id: '1', name: 'Real Madrid'),
    Club(id: '2', name: 'FC Barcelona'),
    Club(id: '3', name: 'Atlético Madrid'),
  ];
  List<Team> _teams = [
    Team(id: 'a', name: 'Juvenil A', category: 'Juvenil', clubId: '1'),
    Team(id: 'b', name: 'Cadete B', category: 'Cadete', clubId: '2'),
    Team(id: 'c', name: 'Infantil C', category: 'Infantil', clubId: '3'),
  ];

  List<Team> get _filteredTeams => _selectedClub == null ? [] : _teams.where((t) => t.clubId == _selectedClub!.id).toList();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 2)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(useMaterial3: true), child: child!),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClub == null || _selectedTeam == null || _selectedDate == null) return;
    setState(() => _loading = true);
    _formKey.currentState!.save();
    final req = FriendlyMatchRequest(
      id: '',
      fromClubId: 'myClubId', // TODO: obtener del usuario
      fromTeamId: 'myTeamId', // TODO: obtener del usuario
      toClubId: _selectedClub!.id,
      toTeamId: _selectedTeam!.id,
      status: FriendlyMatchRequestStatus.pending,
      proposedDate: _selectedDate!,
      proposedLocation: _location!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: _notes,
    );
    await FriendlyMatchService.instance.createRequest(req);
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar amistoso')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            // Glass blur premium: solo si usas BackdropFilter
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Selecciona rival', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                DropdownButtonFormField<Club>(
                  value: _selectedClub,
                  items: _clubs.map((club) => DropdownMenuItem(value: club, child: Text(club.name))).toList(),
                  onChanged: (club) => setState(() => _selectedClub = club),
                  decoration: const InputDecoration(labelText: 'Club rival', border: OutlineInputBorder()),
                  validator: (v) => v == null ? 'Selecciona un club' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Team>(
                  value: _selectedTeam,
                  items: _filteredTeams.map((team) => DropdownMenuItem(value: team, child: Text(team.name))).toList(),
                  onChanged: (team) => setState(() => _selectedTeam = team),
                  decoration: const InputDecoration(labelText: 'Equipo rival', border: OutlineInputBorder()),
                  validator: (v) => v == null ? 'Selecciona un equipo' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: _selectedDate == null ? '' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: 'Fecha propuesta',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (_) => _selectedDate == null ? 'Selecciona una fecha' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Lugar', border: OutlineInputBorder()),
                  onSaved: (v) => _location = v,
                  validator: (v) => (v == null || v.isEmpty) ? 'Indica el lugar' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Notas (opcional)', border: OutlineInputBorder()),
                  onSaved: (v) => _notes = v,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Enviar solicitud'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  onPressed: _loading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
