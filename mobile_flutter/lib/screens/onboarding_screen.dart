import 'package:flutter/material.dart';
import 'package:mobile_flutter/models/auth.dart';
import 'package:mobile_flutter/services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  final User user;
  final VoidCallback? onCompleted;

  const OnboardingScreen({super.key, required this.user, this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  int _currentPage = 0;
  String? _selectedRole;
  String? _selectedClubId;
  String? _selectedTeamId;

  late List<_ClubOption> _clubs;

  bool get _shouldSkipTeamStep => _selectedRole == 'fan';

  static const List<_RoleOption> _availableRoles = [
    _RoleOption(
      id: 'coach',
      title: '🏆 Entrenador',
      description: 'Planifica entrenamientos, gestiona tu plantilla y sigue el progreso del equipo.',
    ),
    _RoleOption(
      id: 'staff',
      title: '📝 Staff',
      description: 'Coordina logistica, eventos y comunicacion con el club.',
    ),
    _RoleOption(
      id: 'fan',
      title: '🎉 Aficionado',
      description: 'Sigue a tus equipos favoritos y mantente al dia con sus partidos.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _selectedRole = widget.user.role.displayName.isNotEmpty ? widget.user.role.displayName : null;
    _clubs = _buildInitialClubs();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<_ClubOption> _buildInitialClubs() => const [
        _ClubOption(
          id: 'club_real_madrid',
          name: 'Real Madrid CF',
          city: 'Madrid, Espana',
          teams: [
            _TeamOption(id: 'rm_juvenil_a', name: 'Juvenil A', category: 'Sub-19'),
            _TeamOption(id: 'rm_cadete_a', name: 'Cadete A', category: 'Sub-16'),
            _TeamOption(id: 'rm_femenino', name: 'Femenino', category: 'Liga F'),
          ],
        ),
        _ClubOption(
          id: 'club_fc_barcelona',
          name: 'FC Barcelona',
          city: 'Barcelona, Espana',
          teams: [
            _TeamOption(id: 'fcb_juvenil_a', name: 'Juvenil A', category: 'Sub-19'),
            _TeamOption(id: 'fcb_infantil_a', name: 'Infantil A', category: 'Sub-14'),
          ],
        ),
        _ClubOption(
          id: 'club_atletico',
          name: 'Atletico de Madrid',
          city: 'Madrid, Espana',
          teams: [
            _TeamOption(id: 'atm_femenino', name: 'Femenino', category: 'Liga F'),
            _TeamOption(id: 'atm_academia', name: 'Academia', category: 'Formacion'),
          ],
        ),
      ];

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    if (!_pageController.hasClients) {
      _pageController.jumpToPage(page);
      return;
    }
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (!_isStepValid(_currentPage)) {
      _showStepError(_currentPage);
      return;
    }

    if (_shouldSkipTeamStep && _currentPage == 1) {
      _completeOnboarding();
      return;
    }

    if (_currentPage >= 2) {
      _completeOnboarding();
      return;
    }

    _goToPage(_currentPage + 1);
  }

  void _previousPage() {
    if (_currentPage == 0) {
      return;
    }
    _goToPage(_currentPage - 1);
  }

  bool _isStepValid(int step) {
    switch (step) {
      case 0:
        return _selectedRole != null;
      case 1:
        return _shouldSkipTeamStep ? true : _selectedClubId != null;
      case 2:
        return _shouldSkipTeamStep ? true : _selectedTeamId != null;
      default:
        return true;
    }
  }

  void _showStepError(int step) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    String message;
    switch (step) {
      case 0:
        message = 'Selecciona un rol para continuar.';
        break;
      case 1:
        message = _shouldSkipTeamStep
            ? 'Pulsa "Finalizar" para terminar.'
            : 'Selecciona o crea un club.';
        break;
      case 2:
        message = _shouldSkipTeamStep
            ? 'Pulsa "Finalizar" para terminar.'
            : 'Selecciona o crea un equipo.';
        break;
      default:
        message = 'Completa el paso antes de continuar.';
    }

    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _onRoleSelected(String roleId) {
    setState(() {
      _selectedRole = roleId;
      if (_shouldSkipTeamStep) {
        _selectedClubId = null;
        _selectedTeamId = null;
      }
    });
  }

  void _onClubSelected(String clubId) {
    final club = _clubs.firstWhere(
      (element) => element.id == clubId,
      orElse: _ClubOption.empty,
    );
    if (club.id.isEmpty) {
      return;
    }

    setState(() {
      _selectedClubId = clubId;
      _selectedTeamId = club.teams.isNotEmpty ? club.teams.first.id : null;
    });
  }

  void _onTeamSelected(String teamId) {
    setState(() => _selectedTeamId = teamId);
  }

  Future<void> _showAddClubDialog() async {
    final result = await showDialog<_ClubDialogResult>(
      context: context,
      builder: (context) => const _CreateClubDialog(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      final newClub = _ClubOption(
        id: _generateId('club'),
        name: result.name,
        city: result.city.isEmpty ? 'Ciudad desconocida' : result.city,
        teams: const [],
      );
      _clubs = [..._clubs, newClub];
      _selectedClubId = newClub.id;
      _selectedTeamId = null;
    });
  }

  Future<void> _showAddTeamDialog() async {
    if (_selectedClubId == null) {
      return;
    }

    final result = await showDialog<_TeamDialogResult>(
      context: context,
      builder: (context) => const _CreateTeamDialog(
        categories: [
          'Sub-8',
          'Sub-10',
          'Sub-12',
          'Sub-14',
          'Sub-16',
          'Sub-19',
          'Senior',
          'Femenino',
        ],
        formats: [
          'Futbol 11',
          'Futbol 7',
          'Futbol sala',
        ],
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      final selectedClub = _clubs.firstWhere(
        (club) => club.id == _selectedClubId,
        orElse: _ClubOption.empty,
      );
      if (selectedClub.id.isEmpty) {
        return;
      }

      final updatedClub = selectedClub.copyWith(
        teams: [
          ...selectedClub.teams,
          _TeamOption(
            id: _generateId('team'),
            name: result.name,
            category: result.category,
          ),
        ],
      );

      _clubs = _clubs.map((club) => club.id == updatedClub.id ? updatedClub : club).toList();
      _selectedTeamId = updatedClub.teams.last.id;
    });
  }

  Future<void> _completeOnboarding() async {
    final resolvedRole = (_selectedRole ?? widget.user.role.displayName);
    final normalisedTeamId = _shouldSkipTeamStep ? null : _selectedTeamId;

    final updatedUser = widget.user.copyWith(
      role: UserRoleExtension.fromDisplayName(resolvedRole.isEmpty ? widget.user.role.displayName : resolvedRole),
      activeClubId: _selectedClubId,
      activeTeamId: normalisedTeamId,
    );

    AuthService.instance.setCurrentUser(updatedUser);
    await AuthService.instance.persistOnboardingSnapshot();

    widget.onCompleted?.call();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa tu perfil'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildRoleStep(),
                _buildClubStep(),
                _buildTeamStep(),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  // All legacy onboarding private builder methods removed

  String _generateId(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}

class _RoleCard extends StatelessWidget {
  final _RoleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.35) : colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              option.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              option.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubTile extends StatelessWidget {
  final _ClubOption club;
  final bool isSelected;
  final VoidCallback onTap;

  const _ClubTile({
    required this.club,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = club.name.isNotEmpty ? club.name.substring(0, 1).toUpperCase() : '?';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.35) : colorScheme.surface,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              foregroundColor: colorScheme.primary,
              child: Text(initials),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (club.city.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      club.city,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${club.teams.length} equipos',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _TeamTile extends StatelessWidget {
  final _TeamOption team;
  final bool isSelected;
  final VoidCallback onTap;

  const _TeamTile({
    required this.team,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.35) : colorScheme.surface,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              foregroundColor: colorScheme.primary,
              child: const Icon(Icons.shield),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    team.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _RoleOption {
  final String id;
  final String title;
  final String description;

  const _RoleOption({required this.id, required this.title, required this.description});
}

class _ClubOption {
  final String id;
  final String name;
  final String city;
  final List<_TeamOption> teams;

  const _ClubOption({
    required this.id,
    required this.name,
    required this.city,
    required this.teams,
  });

  _ClubOption copyWith({
    String? id,
    String? name,
    String? city,
    List<_TeamOption>? teams,
  }) {
    return _ClubOption(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      teams: teams ?? this.teams,
    );
  }

  static _ClubOption empty() => const _ClubOption(id: '', name: '', city: '', teams: []);
}

class _TeamOption {
  final String id;
  final String name;
  final String category;

  const _TeamOption({required this.id, required this.name, required this.category});
}

class _ClubDialogResult {
  final String name;
  final String city;

  const _ClubDialogResult({required this.name, required this.city});
}

class _TeamDialogResult {
  final String name;
  final String category;
  final String format;

  const _TeamDialogResult({required this.name, required this.category, required this.format});
}

class _CreateClubDialog extends StatefulWidget {
  const _CreateClubDialog();

  @override
  State<_CreateClubDialog> createState() => _CreateClubDialogState();
}

class _CreateClubDialogState extends State<_CreateClubDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final city = _cityController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorText = 'El nombre del club es obligatorio');
      return;
    }

    Navigator.of(context).pop(_ClubDialogResult(name: name, city: city));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear club'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del club'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Ciudad'),
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Crear'),
        ),
      ],
    );
  }
}

class _CreateTeamDialog extends StatefulWidget {
  final List<String> categories;
  final List<String> formats;

  const _CreateTeamDialog({required this.categories, required this.formats});

  @override
  State<_CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<_CreateTeamDialog> {
  static const String _customCategoryKey = '__custom__';

  late final TextEditingController _nameController;
  late final TextEditingController _customCategoryController;
  late String _selectedCategory;
  late String _selectedFormat;
  bool _useCustomCategory = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _customCategoryController = TextEditingController();
    _selectedCategory = widget.categories.isNotEmpty ? widget.categories.first : _customCategoryKey;
    _selectedFormat = widget.formats.isNotEmpty ? widget.formats.first : 'Futbol 11';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final String categoryValue;

    if (_useCustomCategory) {
      categoryValue = _customCategoryController.text.trim();
      if (categoryValue.isEmpty) {
        setState(() => _errorText = 'Introduce la categoria del equipo');
        return;
      }
    } else {
      categoryValue = _selectedCategory;
      if (categoryValue == _customCategoryKey) {
        setState(() => _errorText = 'Selecciona la categoria del equipo');
        return;
      }
    }

    if (name.isEmpty) {
      setState(() => _errorText = 'El nombre del equipo es obligatorio');
      return;
    }

    Navigator.of(context).pop(
      _TeamDialogResult(name: name, category: categoryValue, format: _selectedFormat),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = [
      ...widget.categories.map(
        (category) => DropdownMenuItem<String>(value: category, child: Text(category)),
      ),
      const DropdownMenuItem<String>(
        value: _customCategoryKey,
        child: Text('Personalizada'),
      ),
    ];

    return AlertDialog(
      title: const Text('Crear equipo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del equipo'),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Categoria'),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _useCustomCategory ? _customCategoryKey : _selectedCategory,
                  isExpanded: true,
                  items: entries,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      if (value == _customCategoryKey) {
                        _useCustomCategory = true;
                        _customCategoryController.text = '';
                      } else {
                        _useCustomCategory = false;
                        _selectedCategory = value;
                      }
                      _errorText = null;
                    });
                  },
                ),
              ),
            ),
            if (_useCustomCategory)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  controller: _customCategoryController,
                  decoration: const InputDecoration(labelText: 'Nombre de la categoria'),
                ),
              ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Formato'),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFormat,
                  isExpanded: true,
                  items: widget.formats
                      .map(
                        (format) => DropdownMenuItem<String>(
                          value: format,
                          child: Text(format),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedFormat = value;
                    });
                  },
                ),
              ),
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
