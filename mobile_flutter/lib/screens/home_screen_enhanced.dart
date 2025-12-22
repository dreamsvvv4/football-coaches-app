import 'package:flutter/material.dart';

/// Minimal, compiling placeholder for the previously corrupted enhanced home screen.
///
/// This file is imported by `screens/home/main_app.dart`, so it must compile even if
/// the enhanced UI is not currently in use.
class HomeScreenEnhanced extends StatelessWidget {
  const HomeScreenEnhanced({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home (enhanced)  coming soon'),
      ),
    );
  }
}
