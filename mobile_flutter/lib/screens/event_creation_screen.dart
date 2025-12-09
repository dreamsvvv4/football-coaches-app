import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart'; // Uses ActionButton
import '../services/agenda_service.dart';
import '../models/club_event.dart';
import '../services/club_event_service.dart';
import '../services/permission_service.dart';

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({super.key});

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  ClubEventType _type = ClubEventType.match; // match/training/announcement/other
  ClubEventScope _scope = ClubEventScope.wholeClub;
  String? _teamId;
  List<String> _audience = const [];
  final _audienceController = TextEditingController();
  bool _isRecurring = false;
  RecurrenceFrequency _freq = RecurrenceFrequency.weekly;
  List<int> _weekdays = [DateTime.tuesday];
  DateTime? _recurrenceStart;
  DateTime? _recurrenceEnd;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final when = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    // Map type for styling elsewhere; no icon stored on model
    // Build ClubEvent for premium distribution
    final end = when.add(const Duration(hours: 2));
    final base = ClubEvent(
      id: 'club_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _notesController.text.trim(),
      start: when,
      end: end,
      type: _type,
      createdByUserId: 'currentUser',
      scope: _scope,
      teamId: _teamId,
      audienceUserIds: _scope == ClubEventScope.customAudience ? _audience : null,
      recurrence: _isRecurring && _recurrenceEnd != null
          ? RecurrenceRule(
              frequency: _freq,
              interval: 1,
              weekdays: _freq == RecurrenceFrequency.weekly ? _weekdays : null,
              until: _recurrenceEnd!,
            )
          : null,
    );

    ClubEventService.instance.createEvent(base);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              DropdownButtonFormField<ClubEventType>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: ClubEventType.match, child: Text('Partido')),
                  DropdownMenuItem(value: ClubEventType.training, child: Text('Entrenamiento')),
                  DropdownMenuItem(value: ClubEventType.announcement, child: Text('Anuncio')),
                  DropdownMenuItem(value: ClubEventType.other, child: Text('Otro')),
                ],
                onChanged: (v) => setState(() => _type = v ?? ClubEventType.match),
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              DropdownButtonFormField<ClubEventScope>(
                value: _scope,
                items: const [
                  DropdownMenuItem(value: ClubEventScope.wholeClub, child: Text('Todo el club')),
                  DropdownMenuItem(value: ClubEventScope.team, child: Text('Un equipo')),
                  DropdownMenuItem(value: ClubEventScope.customAudience, child: Text('Audiencia personalizada')),
                ],
                onChanged: (v) => setState(() => _scope = v ?? ClubEventScope.wholeClub),
                decoration: const InputDecoration(labelText: 'Ámbito'),
              ),
              if (_scope == ClubEventScope.team) ...[
                const SizedBox(height: AppTheme.spaceMd),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Equipo (ID)'),
                  onChanged: (v) => _teamId = v.trim().isEmpty ? null : v.trim(),
                ),
              ],
              if (_scope == ClubEventScope.customAudience) ...[
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _audienceController,
                        decoration: const InputDecoration(
                          labelText: 'Añadir usuario por ID',
                          helperText: 'Ejemplo: user_123',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    ElevatedButton(
                      onPressed: () {
                        final v = _audienceController.text.trim();
                        if (v.isNotEmpty && !_audience.contains(v)) {
                          setState(() {
                            _audience = [..._audience, v];
                            _audienceController.clear();
                          });
                        }
                      },
                      child: const Text('Añadir'),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final id in _audience)
                      InputChip(
                        label: Text(id),
                        onDeleted: () {
                          setState(() {
                            _audience = _audience.where((e) => e != id).toList();
                          });
                        },
                      ),
                  ],
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDate,
                      child: Text('Fecha: ${_date.day}/${_date.month}/${_date.year}'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickTime,
                      child: Text('Hora: ${_time.format(context)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notas'),
                minLines: 2,
                maxLines: 4,
              ),
              if (_type == ClubEventType.training && PermissionService.instance.canUsePremiumPlanner()) ...[
                const SizedBox(height: AppTheme.spaceLg),
                SwitchListTile(
                  value: _isRecurring,
                  onChanged: (v) => setState(() => _isRecurring = v),
                  title: const Text('Evento recurrente (semanal/mensual/diario)'),
                ),
                if (_isRecurring) ...[
                  DropdownButtonFormField<RecurrenceFrequency>(
                    value: _freq,
                    items: const [
                      DropdownMenuItem(value: RecurrenceFrequency.weekly, child: Text('Semanal')),
                      DropdownMenuItem(value: RecurrenceFrequency.monthly, child: Text('Mensual')),
                      DropdownMenuItem(value: RecurrenceFrequency.daily, child: Text('Diario')),
                    ],
                    onChanged: (v) => setState(() => _freq = v ?? RecurrenceFrequency.weekly),
                    decoration: const InputDecoration(labelText: 'Periodicidad'),
                  ),
                  if (_freq == RecurrenceFrequency.weekly) ...[
                    const SizedBox(height: AppTheme.spaceSm),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final wd in [
                          DateTime.monday,
                          DateTime.tuesday,
                          DateTime.wednesday,
                          DateTime.thursday,
                          DateTime.friday,
                          DateTime.saturday,
                          DateTime.sunday,
                        ])
                          FilterChip(
                            selected: _weekdays.contains(wd),
                            onSelected: (sel) => setState(() {
                              if (sel) {
                                _weekdays.add(wd);
                              } else {
                                _weekdays.remove(wd);
                              }
                            }),
                            label: Text(_weekdayLabel(wd)),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppTheme.spaceSm),
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _recurrenceStart ?? _date,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) setState(() => _recurrenceStart = picked);
                    },
                    child: Text('Inicio: ${_recurrenceStart != null ? '${_recurrenceStart!.day}/${_recurrenceStart!.month}/${_recurrenceStart!.year}' : '—'}'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _recurrenceEnd ?? _date,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) setState(() => _recurrenceEnd = picked);
                    },
                    child: Text('Fin: ${_recurrenceEnd != null ? '${_recurrenceEnd!.day}/${_recurrenceEnd!.month}/${_recurrenceEnd!.year}' : '—'}'),
                  ),
                ],
              ],
              const Spacer(),
              ActionButton(
                label: 'Guardar',
                onPressed: _submit,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _weekdayLabel(int wd) {
    const names = ['L','M','X','J','V','S','D'];
    return names[wd - 1];
  }
}
