import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TrainingRulesScreen extends StatelessWidget {
  const TrainingRulesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reglas de Entrenamiento')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spaceXl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: AppTheme.shadowMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fitness_center, size: 48, color: AppTheme.primaryGreen),
              const SizedBox(height: AppTheme.spaceLg),
              Text('Reglas de entreno', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppTheme.spaceMd),
              Text('Configura reglas de recurrencia y plantillas de ejercicios.', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
