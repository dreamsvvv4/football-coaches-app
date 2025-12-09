import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EventCreatorScreen extends StatelessWidget {
  const EventCreatorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final uniformController = TextEditingController();
    final notesController = TextEditingController();
    final arrivalController = TextEditingController();
    String tipo = 'Entrenamiento';
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Evento')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spaceXl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: AppTheme.shadowMd,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_box, size: 48, color: AppTheme.primaryGreen),
                const SizedBox(height: AppTheme.spaceLg),
                Text('Creador de eventos premium', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppTheme.spaceMd),
                DropdownButtonFormField<String>(
                  value: tipo,
                  decoration: const InputDecoration(labelText: 'Tipo de evento'),
                  items: const [
                    DropdownMenuItem(value: 'Entrenamiento', child: Text('Entrenamiento')),
                    DropdownMenuItem(value: 'Partido', child: Text('Partido')),
                    DropdownMenuItem(value: 'Anuncio', child: Text('Anuncio')),
                  ],
                  onChanged: (v) => tipo = v ?? 'Entrenamiento',
                ),
                const SizedBox(height: AppTheme.spaceMd),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título del evento')),
                const SizedBox(height: AppTheme.spaceMd),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Ubicación')),
                const SizedBox(height: AppTheme.spaceMd),
                TextField(controller: uniformController, decoration: const InputDecoration(labelText: 'Uniforme a utilizar')),
                const SizedBox(height: AppTheme.spaceMd),
                TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notas extra')),
                const SizedBox(height: AppTheme.spaceMd),
                TextField(controller: arrivalController, decoration: const InputDecoration(labelText: '¿Cuánto tiempo antes hay que estar en el campo? (ej: 30 minutos)')),
                const SizedBox(height: AppTheme.spaceLg),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Crear evento'),
                  onPressed: () {
                    // Aquí iría la lógica real de creación y guardado
                    final info = 'Evento creado: ${titleController.text}\nUbicación: ${locationController.text}\nUniforme: ${uniformController.text}\nNotas: ${notesController.text}\nLlegar: ${arrivalController.text} antes';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(info)));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
