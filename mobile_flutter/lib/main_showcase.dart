import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/ui_showcase_screen.dart';
import 'package:provider/provider.dart';

/// 🎨 DEMO APP - Para visualizar todos los componentes UI/UX
/// 
/// Ejecuta este archivo para ver el showcase completo de componentes.
/// 
/// Para ejecutar:
/// flutter run -t lib/main_showcase.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final themeProvider = ThemeProvider();
  await themeProvider.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const ShowcaseApp(),
    ),
  );
}

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'UI/UX Showcase - Football Coaches',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          home: const UIShowcaseScreen(),
        );
      },
    );
  }
}
