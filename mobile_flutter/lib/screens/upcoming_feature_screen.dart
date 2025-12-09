import 'package:flutter/material.dart';

class UpcomingFeatureScreen extends StatelessWidget {
  const UpcomingFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Próximamente')),
      body: const Center(
        child: Text('Esta función estará disponible pronto.'),
      ),
    );
  }
}
