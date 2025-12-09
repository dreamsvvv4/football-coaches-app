import 'package:flutter/material.dart';

class MatchLiveScreen extends StatelessWidget {
  const MatchLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partido en directo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Marcador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Text('Equipo A', style: TextStyle(fontSize: 24)),
                Text('2 - 1', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                Text('Equipo B', style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Línea de tiempo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(title: Text('12\' Gol — Equipo A — Jugador 7')),
                  ListTile(title: Text('23\' Tarjeta amarilla — Equipo B — Jugador 4')),
                  ListTile(title: Text('45+2\' Gol — Equipo B — Jugador 10')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
