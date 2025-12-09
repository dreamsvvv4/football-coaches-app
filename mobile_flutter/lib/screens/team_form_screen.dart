import 'package:flutter/material.dart';

class TeamFormScreen extends StatefulWidget {
  const TeamFormScreen({super.key});

  @override
  State<TeamFormScreen> createState() => _TeamFormScreenState();
}

class _TeamFormScreenState extends State<TeamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Masculino';
  final _leagueController = TextEditingController();
  final _seasonController = TextEditingController();
  final _coachController = TextEditingController();
  final _assistantController = TextEditingController();
  final _fitnessController = TextEditingController();
  final _delegateController = TextEditingController();
  final _venueController = TextEditingController();
  final _trainingDaysController = TextEditingController();
  final _trainingHoursController = TextEditingController();
  String _modality = 'Fútbol 11';
  final _homeKitController = TextEditingController();
  final _awayKitController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _ageController.dispose();
    _leagueController.dispose();
    _seasonController.dispose();
    _coachController.dispose();
    _assistantController.dispose();
    _fitnessController.dispose();
    _delegateController.dispose();
    _venueController.dispose();
    _trainingDaysController.dispose();
    _trainingHoursController.dispose();
    _homeKitController.dispose();
    _awayKitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Equipo'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Identidad del equipo', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre del equipo', prefixIcon: Icon(Icons.group)),
                        validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'Categoría', prefixIcon: Icon(Icons.category)),
                        validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(labelText: 'Edad (U7, U9, U11...)', prefixIcon: Icon(Icons.cake)),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        items: const [
                          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                          DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                          DropdownMenuItem(value: 'Mixto', child: Text('Mixto')),
                        ],
                        onChanged: (v) => setState(() => _gender = v ?? 'Masculino'),
                        decoration: const InputDecoration(labelText: 'Rama'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _leagueController,
                        decoration: const InputDecoration(labelText: 'Liga', prefixIcon: Icon(Icons.emoji_events)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _seasonController,
                        decoration: const InputDecoration(labelText: 'Temporada (ej: 2025/26)', prefixIcon: Icon(Icons.calendar_today)),
                      ),
                      const SizedBox(height: 24),
                      Text('Cuerpo técnico', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _coachController,
                        decoration: const InputDecoration(labelText: 'Entrenador principal', prefixIcon: Icon(Icons.person)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _assistantController,
                        decoration: const InputDecoration(labelText: 'Segundo entrenador (opcional)', prefixIcon: Icon(Icons.person_outline)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _fitnessController,
                        decoration: const InputDecoration(labelText: 'Preparador físico (opcional)', prefixIcon: Icon(Icons.fitness_center)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _delegateController,
                        decoration: const InputDecoration(labelText: 'Delegado/a (opcional)', prefixIcon: Icon(Icons.admin_panel_settings)),
                      ),
                      const SizedBox(height: 24),
                      Text('Sede y entrenamientos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _venueController,
                        decoration: const InputDecoration(labelText: 'Campo habitual de entrenamiento', prefixIcon: Icon(Icons.sports_soccer)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _trainingDaysController,
                        decoration: const InputDecoration(labelText: 'Días de entrenamiento', prefixIcon: Icon(Icons.calendar_view_day)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _trainingHoursController,
                        decoration: const InputDecoration(labelText: 'Horarios', prefixIcon: Icon(Icons.access_time)),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _modality,
                        items: const [
                          DropdownMenuItem(value: 'Fútbol 11', child: Text('Fútbol 11')),
                          DropdownMenuItem(value: 'Fútbol 7', child: Text('Fútbol 7')),
                          DropdownMenuItem(value: 'Fútbol sala', child: Text('Fútbol sala')),
                        ],
                        onChanged: (v) => setState(() => _modality = v ?? 'Fútbol 11'),
                        decoration: const InputDecoration(labelText: 'Modalidad'),
                      ),
                      const SizedBox(height: 24),
                      Text('Opciones avanzadas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _homeKitController,
                        decoration: const InputDecoration(labelText: 'Color camiseta local', prefixIcon: Icon(Icons.checkroom)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _awayKitController,
                        decoration: const InputDecoration(labelText: 'Color camiseta visitante', prefixIcon: Icon(Icons.checkroom_outlined)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(labelText: 'Notas internas del equipo', prefixIcon: Icon(Icons.note)),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Crear equipo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() == true) {
                            // TODO: Guardar equipo premium
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
