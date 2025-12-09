import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TeamChatScreen extends StatelessWidget {
  const TeamChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat del Equipo')),
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
              Icon(Icons.chat, size: 48, color: AppTheme.primaryGreen),
              const SizedBox(height: AppTheme.spaceLg),
              Text('Chat premium de equipo', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppTheme.spaceMd),
              Text('Comparte mensajes, multimedia y coordina con tu equipo.', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
