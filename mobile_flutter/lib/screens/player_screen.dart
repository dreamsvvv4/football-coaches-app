import 'package:flutter/material.dart';
import '../services/mock_auth_service.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _players = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  void _loadPlayers() async {
    final result = await MockAuthService.getPlayers('team_1');
    if (mounted) {
      setState(() {
        _players = List<Map<String, dynamic>>.from(result['data'] ?? []);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jugadores')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _players.length,
                itemBuilder: (context, i) {
                  final player = _players[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${player['number'] ?? i + 1}'),
                      ),
                      title: Text(player['name'] as String),
                      subtitle: Text(player['position'] as String),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
