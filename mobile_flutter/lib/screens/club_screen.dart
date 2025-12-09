import 'package:flutter/material.dart';

class ClubScreen extends StatefulWidget {
  const ClubScreen({super.key});

  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  bool _loading = true;
  List<Map<String, String>> _teams = [];

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  void _loadClubs() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _teams = [
          {'id': '1', 'name': 'Sub-14', 'category': 'Cadetes'},
          {'id': '2', 'name': 'Sub-18', 'category': 'Juveniles'},
          {'id': '3', 'name': 'Senior A', 'category': 'Adultos'},
        ];
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Clubes y Equipos')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _teams.length,
                itemBuilder: (context, i) {
                  final team = _teams[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.sports_soccer),
                      title: Text(team['name']!),
                      subtitle: Text(team['category']!),
                      onTap: () => Navigator.pushNamed(context, '/team'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
