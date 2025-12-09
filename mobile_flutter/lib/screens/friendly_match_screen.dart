import 'package:flutter/material.dart';

import '../models/friendly_match.dart';
import '../services/auth_service.dart';
import '../services/friendly_match_service.dart';
import '../services/match_service.dart';
import 'match_detail_screen.dart';

class FriendlyMatchScreen extends StatefulWidget {
  const FriendlyMatchScreen({super.key});

  @override
  State<FriendlyMatchScreen> createState() => _FriendlyMatchScreenState();
}

class _FriendlyMatchScreenState extends State<FriendlyMatchScreen> {
  final FriendlyMatchService _service = FriendlyMatchService.instance;
  final TextEditingController _searchController = TextEditingController();

  String _statusFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _service.bootstrapSampleData();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _canCreateFriendly {
    final role = AuthService.instance.currentUser?.role ?? 'coach';
    final perms = AuthService.instance.getActionPermsForRole(role);
    return perms.contains('create_friendly');
  }

  List<FriendlyMatch> _applyFilters(List<FriendlyMatch> matches) {
    return matches.where((match) {
      final statusOk = _statusFilter == 'all' || match.status.internalName == _statusFilter;
      if (!statusOk) return false;
      if (_searchQuery.isEmpty) return true;
      final haystack = '${match.opponentClub} ${match.location} ${match.category}'.toLowerCase();
      return haystack.contains(_searchQuery);
    }).toList();
  }

  Map<FriendlyMatchStatus, int> _statusCounters(List<FriendlyMatch> matches) {
    final counters = <FriendlyMatchStatus, int>{
      FriendlyMatchStatus.proposed: 0,
      FriendlyMatchStatus.accepted: 0,
      FriendlyMatchStatus.rejected: 0,
      FriendlyMatchStatus.cancelled: 0,
    };
    for (final match in matches) {
      counters[match.status] = (counters[match.status] ?? 0) + 1;
    }
    return counters;
  }

  Future<void> _openMatchForm({FriendlyMatch? existing}) async {
    final formKey = GlobalKey<FormState>();
    final opponentController = TextEditingController(text: existing?.opponentClub ?? '');
    final contactController = TextEditingController(text: existing?.opponentContact ?? '');
    final locationController = TextEditingController(text: existing?.location ?? '');
    final notesController = TextEditingController(text: existing?.notes ?? '');
    DateTime scheduledAt = existing?.scheduledAt ?? DateTime.now().add(const Duration(days: 1));
    String category = existing?.category ?? _service.categories.first;

    bool saved = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDate: scheduledAt,
              );
              if (picked != null) {
                setDialogState(() {
                  scheduledAt = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    scheduledAt.hour,
                    scheduledAt.minute,
                  );
                });
              }
            }

            Future<void> pickTime() async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(scheduledAt),
              );
              if (picked != null) {
                setDialogState(() {
                  scheduledAt = DateTime(
                    scheduledAt.year,
                    scheduledAt.month,
                    scheduledAt.day,
                    picked.hour,
                    picked.minute,
                  );
                });
              }
            }

            return AlertDialog(
              title: Text(existing == null ? 'Proponer amistoso' : 'Editar amistoso'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: opponentController,
                        decoration: const InputDecoration(labelText: 'Club rival'),
                        validator: (value) => value == null || value.isEmpty ? 'Introduce el club rival' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: contactController,
                        decoration: const InputDecoration(labelText: 'Contacto (opcional)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: locationController,
                        decoration: const InputDecoration(labelText: 'Ubicación del partido'),
                        validator: (value) => value == null || value.isEmpty ? 'Introduce una ubicación' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration: const InputDecoration(labelText: 'Categoría'),
                        items: _service.categories
                            .map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => category = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Fecha'),
                        subtitle: Text(_formatDate(scheduledAt)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: pickDate,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Hora'),
                        subtitle: Text(_formatTime(scheduledAt)),
                        trailing: const Icon(Icons.access_time),
                        onTap: pickTime,
                      ),
                      TextFormField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Notas (opcional)'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    if (existing == null) {
                      _service.createMatch(
                        opponentClub: opponentController.text.trim(),
                        opponentContact: contactController.text.trim().isEmpty
                            ? null
                            : contactController.text.trim(),
                        location: locationController.text.trim(),
                        scheduledAt: scheduledAt,
                        category: category,
                        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                        createdByMe: true,
                      );
                    } else {
                      _service.updateMatch(
                        existing.id,
                        opponentClub: opponentController.text.trim(),
                        opponentContact: contactController.text.trim().isEmpty
                            ? null
                            : contactController.text.trim(),
                        location: locationController.text.trim(),
                        scheduledAt: scheduledAt,
                        category: category,
                        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                      );
                    }
                    saved = true;
                    Navigator.pop(context);
                  },
                  child: Text(existing == null ? 'Crear' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    opponentController.dispose();
    contactController.dispose();
    locationController.dispose();
    notesController.dispose();

    if (saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(existing == null ? 'Amistoso propuesto' : 'Amistoso actualizado')),
      );
    }
  }

  void _acceptMatch(FriendlyMatch match) {
    _service.respondToInvitation(match.id, FriendlyMatchStatus.accepted);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Has aceptado el amistoso')),
    );
  }

  void _rejectMatch(FriendlyMatch match) {
    _service.respondToInvitation(match.id, FriendlyMatchStatus.rejected);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Has rechazado el amistoso')),
    );
  }

  void _cancelMatch(FriendlyMatch match) {
    _service.cancel(match.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Has cancelado el amistoso')),
    );
  }

  Future<void> _openDetails(FriendlyMatch match) async {
    MatchService.instance.upsertFriendlyMatch(match);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MatchDetailScreen(matchId: match.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Amistosos'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      floatingActionButton: _canCreateFriendly
          ? FloatingActionButton.extended(
              heroTag: 'friendliesFab',
              onPressed: () => _openMatchForm(),
              icon: const Icon(Icons.add),
              label: const Text('Proponer amistoso'),
            )
          : null,
      body: ValueListenableBuilder<List<FriendlyMatch>>(
        valueListenable: _service.matchesNotifier,
        builder: (context, matches, _) {
          final filtered = _applyFilters(matches);
          final counters = _statusCounters(matches);

          return Stack(
            children: [
              const _PageBackdrop(),
              Positioned.fill(
                child: SafeArea(
                  child: RefreshIndicator(
                    color: theme.colorScheme.primary,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      await Future<void>.delayed(const Duration(milliseconds: 350));
                      if (mounted) setState(() {});
                    },
                    child: ListView(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                      children: [
                        _FriendliesHero(
                          totalMatches: matches.length,
                          accepted: counters[FriendlyMatchStatus.accepted] ?? 0,
                          onCreate: _canCreateFriendly ? () => _openMatchForm() : null,
                        ),
                        const SizedBox(height: 20),
                        _FriendliesHeader(total: matches.length, counters: counters),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Buscar por rival, ubicación o categoría',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _StatusFilterBar(
                          current: _statusFilter,
                          onChanged: (value) => setState(() => _statusFilter = value),
                        ),
                        const SizedBox(height: 16),
                        if (filtered.isEmpty)
                          const _EmptyState()
                        else ...[
                          ...List.generate(filtered.length, (index) {
                            final match = filtered[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: index == filtered.length - 1 ? 0 : 16),
                              child: _FriendlyMatchCard(
                                match: match,
                                onAccept: !match.createdByMe && match.status == FriendlyMatchStatus.proposed
                                    ? () => _acceptMatch(match)
                                    : null,
                                onReject: !match.createdByMe && match.status == FriendlyMatchStatus.proposed
                                    ? () => _rejectMatch(match)
                                    : null,
                                onCancel: match.createdByMe && match.status != FriendlyMatchStatus.cancelled
                                    ? () => _cancelMatch(match)
                                    : null,
                                onEdit: match.createdByMe && match.status != FriendlyMatchStatus.cancelled
                                    ? () => _openMatchForm(existing: match)
                                    : null,
                                onView: () => _openDetails(match),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _FriendliesHeader extends StatelessWidget {
  final int total;
  final Map<FriendlyMatchStatus, int> counters;

  const _FriendliesHeader({required this.total, required this.counters});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pending = counters[FriendlyMatchStatus.proposed] ?? 0;
    final confirmed = counters[FriendlyMatchStatus.accepted] ?? 0;
    final rejected = counters[FriendlyMatchStatus.rejected] ?? 0;
    final cancelled = counters[FriendlyMatchStatus.cancelled] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatPill(
              label: 'Totales',
              value: '$total',
              color: theme.colorScheme.primary,
              icon: Icons.sports_soccer,
            ),
            _StatPill(
              label: 'Pendientes',
              value: '$pending',
              color: const Color(0xFFF4A259),
              icon: Icons.hourglass_empty,
            ),
            _StatPill(
              label: 'Confirmados',
              value: '$confirmed',
              color: const Color(0xFF2F9F85),
              icon: Icons.verified_user,
            ),
            _StatPill(
              label: 'Rechazados/Cancelados',
              value: '${rejected + cancelled}',
              color: const Color(0xFFD64550),
              icon: Icons.block,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 164,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.16),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color.withValues(alpha: 0.8))),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _StatusFilterBar({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = <String, String>{
      'all': 'Todos',
      FriendlyMatchStatus.proposed.internalName: FriendlyMatchStatus.proposed.label,
      FriendlyMatchStatus.accepted.internalName: FriendlyMatchStatus.accepted.label,
      FriendlyMatchStatus.rejected.internalName: FriendlyMatchStatus.rejected.label,
      FriendlyMatchStatus.cancelled.internalName: FriendlyMatchStatus.cancelled.label,
    };

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final entry = options.entries.elementAt(index);
          final selected = current == entry.key;
          return FilterChip(
            label: Text(entry.value),
            selected: selected,
            onSelected: (_) => onChanged(entry.key),
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: options.length,
      ),
    );
  }
}

class _PageBackdrop extends StatelessWidget {
  const _PageBackdrop();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primary.withValues(alpha: 0.18),
            primary.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _FriendliesHero extends StatelessWidget {
  final int totalMatches;
  final int accepted;
  final VoidCallback? onCreate;

  const _FriendliesHero({
    required this.totalMatches,
    required this.accepted,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.colorScheme.primary,
        theme.colorScheme.primary.withValues(alpha: 0.75),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coordina tus amistosos',
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Envía invitaciones, confirma rivales y prepara el plan de partido con tu staff.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.78)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _HeroMetric(label: 'Activos', value: '$totalMatches'),
              const SizedBox(width: 18),
              _HeroMetric(label: 'Confirmados', value: '$accepted'),
              const Spacer(),
              if (onCreate != null)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo amistoso'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FriendlyMatchCard extends StatelessWidget {
  final FriendlyMatch match;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;
  final VoidCallback? onView;

  const _FriendlyMatchCard({
    required this.match,
    this.onAccept,
    this.onReject,
    this.onCancel,
    this.onEdit,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(match.status);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'vs ${match.opponentClub}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('${_formatFullDate(match.scheduledAt)} · ${match.location}'),
                      const SizedBox(height: 2),
                      Text('Categoría: ${match.category}'),
                      if (match.notes != null && match.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(match.notes!, style: Theme.of(context).textTheme.bodySmall),
                        ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(match.status.label),
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MatchTimelinePreview(matchId: match.id),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onAccept != null)
                  FilledButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Aceptar'),
                  ),
                if (onReject != null)
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Rechazar'),
                  ),
                if (onEdit != null)
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                if (onCancel != null)
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar'),
                  ),
                FilledButton.tonalIcon(
                  onPressed: onView,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Ver detalles'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(FriendlyMatchStatus status) {
    switch (status) {
      case FriendlyMatchStatus.accepted:
        return Colors.green.shade700;
      case FriendlyMatchStatus.proposed:
        return Colors.orange.shade700;
      case FriendlyMatchStatus.rejected:
        return Colors.red.shade700;
      case FriendlyMatchStatus.cancelled:
        return Colors.grey.shade600;
    }
  }

  String _formatFullDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year · $hour:$minute';
  }
}

class _MatchTimelinePreview extends StatelessWidget {
  final String matchId;

  const _MatchTimelinePreview({required this.matchId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MatchDetail>(
      stream: MatchService.instance.watchMatch(matchId),
      builder: (context, snapshot) {
        final detail = snapshot.data;
        if (detail == null || detail.timeline.isEmpty) {
          return Text(
            'Sin incidencias registradas todavía',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        final events = detail.timeline.reversed.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Últimas incidencias', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            ...events.map(
              (event) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(_iconFor(event.type), size: 20),
                title: Text('${event.minute} · ${event.description}'),
                subtitle: event.recordedByName != null
                    ? Text('Registrado por ${event.recordedByName!}', style: Theme.of(context).textTheme.bodySmall)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'goal':
        return Icons.sports_soccer;
      case 'yellow_card':
        return Icons.square_foot;
      case 'red_card':
        return Icons.report;
      case 'sub':
        return Icons.swap_horiz;
      case 'match_end':
        return Icons.flag;
      default:
        return Icons.info_outline;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer_outlined, size: 56, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              'Sin resultados con estos filtros',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ajusta la búsqueda o crea un nuevo amistoso para coordinar con otro club.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.72)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
