import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/permission_service.dart';
import '../services/auth_service.dart';
import 'premium_widgets.dart';

class PremiumEmptyState extends StatelessWidget {
  final String headline;
  final String subtext;
  final VoidCallback? onCreate;
  final bool? canCreateOverride;

  const PremiumEmptyState({
    super.key,
    this.headline = 'Sin eventos por ahora',
    this.subtext = 'Aquí verás tus próximos partidos, entrenamientos y actividades',
    this.onCreate,
    this.canCreateOverride,
  });

  bool _canCreate(BuildContext context) {
    if (canCreateOverride != null) return canCreateOverride!;
    return PermissionService.canRecordMatch(AuthService.instance.activeContext);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showCta = onCreate != null && _canCreate(context);

    return Padding(
      padding: const EdgeInsets.all(AppTheme.space2xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.10),
                  theme.colorScheme.secondary.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.event_available,
              size: 52,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXl),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            subtext,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          if (showCta) ...[
            const SizedBox(height: AppTheme.spaceLg),
            ActionButton(
              label: 'Crear evento',
              onPressed: onCreate!,
              isFullWidth: false,
            ),
          ],
        ],
      ),
    );
  }
}
