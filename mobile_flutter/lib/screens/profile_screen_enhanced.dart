import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth.dart';
import '../widgets/animations.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/form_widgets.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/dashboard_widgets.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreenEnhanced extends StatefulWidget {
  const ProfileScreenEnhanced({super.key});

  @override
  State<ProfileScreenEnhanced> createState() => _ProfileScreenEnhancedState();
}

class _ProfileScreenEnhancedState extends State<ProfileScreenEnhanced> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _role = 'coach';
  bool _notificationsEnabled = true;
  bool _liveUpdatesEnabled = true;
  bool _emailNotifications = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _role = user?.role.displayName ?? 'coach';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: PremiumRefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(AppTheme.spaceLg),
                children: [
                  // Profile Header
                  FadeInSlideUp(
                    child: _ProfileHeader(
                      name: user?.name ?? 'Usuario',
                      role: _getRoleLabel(_role),
                      email: user?.email ?? '',
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXl),

                  // Stats
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 100),
                    child: QuickStatsGrid(
                      stats: [
                        QuickStat(
                          label: 'Partidos',
                          value: '24',
                          icon: Icons.sports_soccer,
                          color: AppTheme.primaryGreen,
                        ),
                        QuickStat(
                          label: 'Victorias',
                          value: '18',
                          icon: Icons.emoji_events,
                          color: AppTheme.success,
                        ),
                        QuickStat(
                          label: 'Equipos',
                          value: '3',
                          icon: Icons.groups,
                          color: AppTheme.info,
                        ),
                        QuickStat(
                          label: 'Torneos',
                          value: '2',
                          icon: Icons.military_tech,
                          color: AppTheme.accentOrange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXl),

                  // Personal Info Section
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 150),
                    child: _SectionCard(
                      title: 'Información Personal',
                      icon: Icons.person,
                      children: [
                        PremiumTextField(
                          label: 'Nombre completo',
                          controller: _nameController,
                          prefixIcon: Icons.person,
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        PremiumTextField(
                          label: 'Email',
                          controller: _emailController,
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        PremiumDropdown<String>(
                          label: 'Rol',
                          value: _role,
                          items: const [
                            DropdownMenuItem(value: 'coach', child: Text('Entrenador')),
                            DropdownMenuItem(value: 'player', child: Text('Jugador')),
                            DropdownMenuItem(value: 'scout', child: Text('Scout')),
                            DropdownMenuItem(value: 'referee', child: Text('Árbitro')),
                          ],
                          onChanged: (value) {
                            setState(() => _role = value ?? 'coach');
                          },
                          prefixIcon: Icons.badge,
                        ),
                        const SizedBox(height: AppTheme.spaceXl),
                        ActionButton(
                          label: 'Guardar Cambios',
                          onPressed: _saveProfile,
                          icon: Icons.save,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),

                  // Appearance Section
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 200),
                    child: _SectionCard(
                      title: 'Apariencia',
                      icon: Icons.palette,
                      children: [
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return PremiumSwitch(
                              label: 'Modo Oscuro',
                              subtitle: 'Activa el tema oscuro para mejor visibilidad nocturna',
                              value: themeProvider.isDarkMode,
                              onChanged: (value) => themeProvider.toggleTheme(),
                              icon: Icons.dark_mode,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),

                  // Notifications Section
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 250),
                    child: _SectionCard(
                      title: 'Notificaciones',
                      icon: Icons.notifications,
                      children: [
                        PremiumSwitch(
                          label: 'Notificaciones Push',
                          subtitle: 'Recibe alertas de partidos y eventos',
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() => _notificationsEnabled = value);
                          },
                          icon: Icons.notifications_active,
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        PremiumSwitch(
                          label: 'Actualizaciones en Vivo',
                          subtitle: 'Recibe resultados en tiempo real',
                          value: _liveUpdatesEnabled,
                          onChanged: (value) {
                            setState(() => _liveUpdatesEnabled = value);
                          },
                          icon: Icons.live_tv,
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        PremiumSwitch(
                          label: 'Email de Resumen',
                          subtitle: 'Resumen semanal de actividad',
                          value: _emailNotifications,
                          onChanged: (value) {
                            setState(() => _emailNotifications = value);
                          },
                          icon: Icons.email,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),

                  // Achievements Section
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 300),
                    child: _SectionCard(
                      title: 'Logros',
                      icon: Icons.emoji_events,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AchievementBadge(
                                label: 'Primer Partido',
                                icon: Icons.sports_soccer,
                                color: AppTheme.primaryGreen,
                                isUnlocked: true,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spaceMd),
                            Expanded(
                              child: AchievementBadge(
                                label: '10 Victorias',
                                icon: Icons.emoji_events,
                                color: AppTheme.accentOrange,
                                isUnlocked: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        Row(
                          children: [
                            Expanded(
                              child: AchievementBadge(
                                label: 'Campeón',
                                icon: Icons.military_tech,
                                color: AppTheme.warning,
                                isUnlocked: false,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spaceMd),
                            Expanded(
                              child: AchievementBadge(
                                label: 'Invicto',
                                icon: Icons.shield,
                                color: AppTheme.info,
                                isUnlocked: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),

                  // About Section
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 350),
                    child: _SectionCard(
                      title: 'Acerca de',
                      icon: Icons.info,
                      children: [
                        _InfoRow(
                          icon: Icons.apps,
                          label: 'Versión',
                          value: '1.0.0',
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        _InfoRow(
                          icon: Icons.code,
                          label: 'Build',
                          value: '100',
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        _InfoRow(
                          icon: Icons.security,
                          label: 'Licencia',
                          value: 'MIT',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),

                  // Danger Zone
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spaceLg),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning, color: AppTheme.error),
                              const SizedBox(width: AppTheme.spaceSm),
                              Text(
                                'Zona de peligro',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spaceMd),
                          OutlinedButton.icon(
                            onPressed: _deleteAccount,
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Eliminar Cuenta'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.error,
                              side: const BorderSide(color: AppTheme.error),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spaceMd,
                                horizontal: AppTheme.spaceLg,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space2xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.info.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      NotificationToast.show(
        context,
        title: 'Perfil actualizado',
        message: 'Los cambios se han guardado correctamente',
        icon: Icons.check_circle,
      );
    }
  }

  void _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: const Text(
          'Esta acción no se puede deshacer. Se eliminarán todos tus datos permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      NotificationToast.show(
        context,
        title: 'Cuenta eliminada',
        message: 'Tu cuenta ha sido eliminada correctamente',
        icon: Icons.delete,
      );
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'coach':
        return 'Entrenador';
      case 'player':
        return 'Jugador';
      case 'scout':
        return 'Scout';
      case 'referee':
        return 'Árbitro';
      default:
        return role;
    }
  }
}

// Widgets
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String role;
  final String email;

  const _ProfileHeader({
    required this.name,
    required this.role,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceXl),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        children: [
          PulseAnimation(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Text(
            name,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMd,
              vertical: AppTheme.spaceSm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text(
              role,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceXl),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                ),
                child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXl),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
