import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CallUpsScreen extends StatelessWidget {
  const CallUpsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convocatorias')),
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
              Icon(Icons.groups, size: 48, color: AppTheme.secondaryTeal),
              const SizedBox(height: AppTheme.spaceLg),
              Text('Gestión de convocatorias', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppTheme.spaceMd),
              Text('Crea, edita y notifica convocatorias a jugadores y padres.', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
