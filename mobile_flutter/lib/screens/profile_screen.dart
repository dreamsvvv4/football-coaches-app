import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/mock_auth_service.dart';
import '../services/venue_service.dart';
import '../models/venue.dart';
import '../models/auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _role = 'coach';
  String? _selectedClub;
  String? _selectedTeam;
  bool _loading = false;
  Map<String, bool> _tabPrefsForRole = {
    'home': true,
    'team': true,
    'tournaments': false,
    'chat': true,
    'live': false,
    'profile': true,
  };
  Map<String, bool> _actionPermsForRole = {
    'create_friendly': false,
    'edit_player': false,
    'match_live_events': false,
    'team_chat': true,
    'configure_tournament': false,
    'open_match_sheet': false,
    'record_incident': false,
    'follow_team': true,
    'moderate': false,
  };

  List<Map<String, dynamic>> _clubs = [];
  List<Map<String, dynamic>> _teams = [];
  String? _selectedVenueId;
  List<Venue> _venues = [];

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    
    // Convert role to String if needed
    var role = user?.role;
    if (role is Enum) {
      _role = role.toString().split('.').last.toLowerCase();
    } else {
      _role = (role?.toString() ?? 'coach').toLowerCase();
    }
    
    _selectedClub = user?.activeClubId;
    _selectedTeam = user?.activeTeamId;
    _loadTabPrefs();
    _loadClubs();
    _loadVenues();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadTabPrefs() {
    final visible = AuthService.instance.getVisibleTabsForRole(_role);
    _tabPrefsForRole = {
      'home': visible.contains('home'),
      'team': visible.contains('team'),
      'tournaments': visible.contains('tournaments'),
      'chat': visible.contains('chat'),
      'live': visible.contains('live'),
      'profile': visible.contains('profile'),
    };
    final perms = AuthService.instance.getActionPermsForRole(_role);
    _actionPermsForRole = {
      'create_friendly': perms.contains('create_friendly'),
      'edit_player': perms.contains('edit_player'),
      'match_live_events': perms.contains('match_live_events'),
      'team_chat': perms.contains('team_chat'),
      'configure_tournament': perms.contains('configure_tournament'),
      'open_match_sheet': perms.contains('open_match_sheet'),
      'record_incident': perms.contains('record_incident'),
      'follow_team': perms.contains('follow_team'),
      'moderate': perms.contains('moderate'),
    };
  }

  Future<void> _loadVenues() async {
    setState(() => _loading = true);
    try {
      await VenueService.instance.init();
      if (!mounted) return;
      setState(() {
        _venues = VenueService.instance.getAllVenues();
        if (_venues.isNotEmpty && _selectedVenueId == null) {
          _selectedVenueId = _venues.first.id;
        }
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadClubs() async {
    setState(() => _loading = true);
    try {
      final res = await MockAuthService.getClubs();
      if (!mounted) return;
      if (res['success'] == true) {
        final data = List<Map<String, dynamic>>.from(res['data'] as List);
        String? nextClub = _selectedClub;
        if (nextClub != null && data.every((c) => c['id'] != nextClub)) {
          nextClub = null;
        }
        setState(() {
          _clubs = data;
          _selectedClub = nextClub;
          if (_selectedClub == null) {
            _teams = [];
            _selectedTeam = null;
          }
        });
        if (_selectedClub != null) {
          await _loadTeams(_selectedClub!, propagateLoading: false);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadTeams(String clubId, {bool propagateLoading = true}) async {
    if (propagateLoading) {
      setState(() => _loading = true);
    }
    final res = await MockAuthService.getTeams(clubId);
    if (!mounted) return;
    if (res['success'] == true) {
      final data = List<Map<String, dynamic>>.from(res['data'] as List);
      setState(() {
        _teams = data;
        if (_selectedTeam != null && _teams.every((t) => t['id'] != _selectedTeam)) {
          _selectedTeam = null;
        }
      });
    }
    if (propagateLoading && mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user loaded')));
      setState(() => _loading = false);
      return;
    }

    late final User updated;
    
    // Update user with new values
    updated = user.copyWith(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      activeClubId: _selectedClub,
      activeTeamId: _selectedTeam,
    );

    AuthService.instance.setCurrentUser(updated);
    await AuthService.instance.persistOnboardingSnapshot();
    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final clubValue = _clubs.any((c) => c['id'] == _selectedClub) ? _selectedClub : null;
                final teamValue = _teams.any((t) => t['id'] == _selectedTeam) ? _selectedTeam : null;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'coach', label: Text('Entrenador'), icon: Icon(Icons.school)),
                        ButtonSegment(value: 'player', label: Text('Jugador'), icon: Icon(Icons.sports_soccer)),
                        ButtonSegment(value: 'club_admin', label: Text('Club Admin'), icon: Icon(Icons.admin_panel_settings)),
                        ButtonSegment(value: 'referee', label: Text('Árbitro'), icon: Icon(Icons.gavel)),
                        ButtonSegment(value: 'fan', label: Text('Aficionado'), icon: Icon(Icons.favorite)),
                        ButtonSegment(value: 'superadmin', label: Text('Superadmin'), icon: Icon(Icons.security)),
                      ],
                      selected: {_role},
                      onSelectionChanged: (s) => setState(() {
                        _role = s.first;
                        _loadTabPrefs();
                      }),
                    ),
                    const SizedBox(height: 8),
                    _RoleCapabilities(role: _role),
                    const SizedBox(height: 12),
                    _EditableTabPrefs(
                      prefs: _tabPrefsForRole,
                      onChanged: (key, value) => setState(() => _tabPrefsForRole[key] = value),
                    ),
                    const SizedBox(height: 12),
                    _EditableActionPerms(
                      perms: _actionPermsForRole,
                      onChanged: (key, value) => setState(() => _actionPermsForRole[key] = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('club_$clubValue'),
                      initialValue: clubValue,
                      decoration: const InputDecoration(labelText: 'Club activo'),
                      items: _clubs
                          .map((c) => DropdownMenuItem(value: c['id'] as String, child: Text(c['name'] as String)))
                          .toList(),
                      onChanged: (v) async {
                        setState(() {
                          _selectedClub = v;
                          _selectedTeam = null;
                          _teams = [];
                        });
                        if (v != null) await _loadTeams(v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('team_$teamValue'),
                      initialValue: teamValue,
                      decoration: const InputDecoration(labelText: 'Equipo activo'),
                      items: _teams
                          .map((t) => DropdownMenuItem(value: t['id'] as String, child: Text(t['name'] as String)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedTeam = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('venue_dropdown_${_venues.length}'),
                      initialValue: _venues.any((v) => v.id == _selectedVenueId) ? _selectedVenueId : null,
                      items: _venues
                          .map((v) => DropdownMenuItem(
                                value: v.id,
                                child: Text(v.name),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedVenueId = v);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Recinto de origen (sede/club)',
                        helperText: 'Selecciona tu campo o estadio principal',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add_location_alt),
                        label: const Text('Gestionar recintos'),
                        onPressed: () async {
                          // Navigate to venues management screen
                          // For now, show a simple dialog
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Gestión de Recintos'),
                              content: const Text(
                                'Accede a "Gestión de Recintos" desde el menú principal para crear, editar o eliminar recintos.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Ok'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.group_add),
                        label: const Text('Crear equipo'),
                        onPressed: () async {
                          final nameController = TextEditingController();
                          String category = 'Alevín';
                          final categories = ['Benjamín','Alevín','Infantil','Cadete','Juvenil','Senior'];
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Nuevo equipo'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(labelText: 'Nombre del equipo'),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    initialValue: category,
                                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                    onChanged: (v) => category = v ?? category,
                                    decoration: const InputDecoration(labelText: 'Categoría'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                                ElevatedButton(
                                  onPressed: () {
                                    if (nameController.text.trim().isEmpty) return;
                                    final id = 'team_${DateTime.now().millisecondsSinceEpoch}';
                                    setState(() {
                                      _teams.add({'id': id, 'name': nameController.text.trim(), 'category': category});
                                      _selectedTeam = id;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Crear'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading ? null : _save,
                        child: _loading ? const CircularProgressIndicator() : const Text('Guardar'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
                  ),
                );
              },
            ),
    );
  }

    @override
    void setState(VoidCallback fn) {
      super.setState(fn);
      // Sin comprobaciones nulas: variables son late y ya inicializadas
      if (_tabPrefsForRole.isEmpty || _actionPermsForRole.isEmpty || _role.isEmpty) {
        return;
      }
      final selectedTabs = _tabPrefsForRole.entries.where((e) => e.value).map((e) => e.key).toList();
      AuthService.instance.setVisibleTabsForRole(_role, selectedTabs);
      final selectedPerms = _actionPermsForRole.entries.where((e) => e.value).map((e) => e.key).toList();
      AuthService.instance.setActionPermsForRole(_role, selectedPerms);
    }
}

class _RoleCapabilities extends StatelessWidget {
  final String role;
  const _RoleCapabilities({required this.role});

  @override
  Widget build(BuildContext context) {
    final items = _capabilitiesFor(role);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Permisos y funciones', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((e) => Chip(label: Text(e))).toList(),
        ),
      ],
    );
  }

  List<String> _capabilitiesFor(String r) {
    switch (r) {
      case 'coach':
        return ['Gestionar equipo', 'Crear amistosos', 'Partido en directo', 'Chat de equipo'];
      case 'player':
        return ['Ver calendario', 'Recibir avisos', 'Chat del equipo'];
      case 'club_admin':
        return ['Gestionar clubes', 'Alta/baja jugadores', 'Configurar torneos'];
      case 'referee':
        return ['Acta del partido', 'Registrar incidencias'];
      case 'fan':
        return ['Seguir equipos', 'Ver resultados'];
      case 'superadmin':
        return ['Control global', 'Gestión de roles', 'Moderación'];
      default:
        return ['Funciones básicas'];
    }
  }
}

class _EditableActionPerms extends StatelessWidget {
  final Map<String, bool> perms;
  final void Function(String key, bool value) onChanged;
  const _EditableActionPerms({required this.perms, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final labels = {
      'create_friendly': 'Crear amistosos',
      'edit_player': 'Editar jugador',
      'match_live_events': 'Eventos en directo',
      'team_chat': 'Chat de equipo',
      'configure_tournament': 'Configurar torneo',
      'open_match_sheet': 'Abrir acta',
      'record_incident': 'Registrar incidencia',
      'follow_team': 'Seguir equipo',
      'moderate': 'Moderación',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Permisos de acciones', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: perms.keys
              .map((k) => FilterChip(
                    selected: perms[k] == true,
                    label: Text(labels[k] ?? k),
                    onSelected: (v) => onChanged(k, v),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _EditableTabPrefs extends StatelessWidget {
  final Map<String, bool> prefs;
  final void Function(String key, bool value) onChanged;
  const _EditableTabPrefs({required this.prefs, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final labels = {
      'home': 'Inicio',
      'team': 'Equipo',
      'tournaments': 'Torneos',
      'chat': 'Chat',
      'live': 'En Directo',
      'profile': 'Perfil',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Visibilidad de pestañas', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: prefs.keys
              .map((k) => FilterChip(
                    selected: prefs[k] == true,
                    label: Text(labels[k] ?? k),
                    onSelected: (v) => onChanged(k, v),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        Text(
          'Edita qué pestañas ve el rol actual. Se aplica al instante.',
          style: Theme.of(context).textTheme.bodySmall,
        )
      ],
    );
  }
}
