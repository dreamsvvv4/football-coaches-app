import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🌓 **THEME PROVIDER** - Dark/Light mode management with smooth animations

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  bool _isAnimating = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isAnimating => _isAnimating;

  /// Initialize theme from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _isAnimating = true;
    notifyListeners();

    // Delay for animation
    await Future.delayed(const Duration(milliseconds: 300));

    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    
    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);

    _isAnimating = false;
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _isAnimating = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);

    _isAnimating = false;
    notifyListeners();
  }
}

/// 🎨 **ANIMATED THEME SWITCHER BUTTON**
class ThemeSwitcher extends StatefulWidget {
  final ThemeProvider themeProvider;

  const ThemeSwitcher({
    super.key,
    required this.themeProvider,
  });

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    if (widget.themeProvider.isDarkMode) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() async {
    if (widget.themeProvider.isDarkMode) {
      await _controller.reverse();
    } else {
      await _controller.forward();
    }
    widget.themeProvider.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: 64,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.lerp(
                    const Color(0xFFFFD54F),
                    const Color(0xFF1E293B),
                    _animation.value,
                  )!,
                  Color.lerp(
                    const Color(0xFFFFA726),
                    const Color(0xFF0F172A),
                    _animation.value,
                  )!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Sun/Moon icons background
                Positioned(
                  left: 8,
                  top: 6,
                  child: Icon(
                    Icons.wb_sunny,
                    size: 18,
                    color: Colors.white.withValues(alpha: 1 - _animation.value),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 6,
                  child: Icon(
                    Icons.nightlight_round,
                    size: 18,
                    color: Colors.white.withValues(alpha: _animation.value),
                  ),
                ),
                
                // Sliding thumb
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _animation.value * 32 + 2,
                  top: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _animation.value > 0.5
                          ? Icons.nightlight_round
                          : Icons.wb_sunny,
                      size: 16,
                      color: _animation.value > 0.5
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFFFA726),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 🌊 **THEME TRANSITION OVERLAY** - Full screen transition animation
class ThemeTransitionOverlay extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const ThemeTransitionOverlay({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  State<ThemeTransitionOverlay> createState() => _ThemeTransitionOverlayState();
}

class _ThemeTransitionOverlayState extends State<ThemeTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(ThemeTransitionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark) {
      _triggerTransition();
    }
  }

  void _triggerTransition() async {
    setState(() => _showOverlay = true);
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _controller.reverse();
    setState(() => _showOverlay = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showOverlay)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: widget.isDark ? Colors.black : Colors.white,
            ),
          ),
      ],
    );
  }
}
