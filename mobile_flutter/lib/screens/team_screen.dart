import 'package:flutter/material.dart';

class PlayerItem {
  int number;
  String name;
  String position;
  String? medicalNote;
  PlayerItem({
    required this.number,
    required this.name,
    required this.position,
    this.medicalNote,
  });
}

class TeamScreen extends StatefulWidget {
  const TeamScreen({Key? key}) : super(key: key);
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final List<PlayerItem> _players = List.generate(
    16,
    (i) => PlayerItem(
      number: i + 1,
      name: 'Jugador ${i + 1}',
      position: i % 4 == 0
          ? 'Portero'
          : i % 3 == 0
              ? 'Defensa'
              : i % 2 == 0
                  ? 'Centrocampista'
                  : 'Delantero',
    ),
  );

  void _addPlayerDialog() {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    String position = 'Portero';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir jugador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'Número'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: position,
              items: ['Portero', 'Defensa', 'Centrocampista', 'Delantero']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  position = value;
                  setState(() {});
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final number = int.tryParse(numberController.text.trim()) ?? 0;
              if (name.isNotEmpty && number > 0) {
                setState(() {
                  _players.add(PlayerItem(
                    number: number,
                    name: name,
                    position: position,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editPlayerDialog(int index) {
    final player = _players[index];
    final nameController = TextEditingController(text: player.name);
    final numberController = TextEditingController(text: player.number.toString());
    String position = player.position;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar jugador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'Número'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: position,
              items: ['Portero', 'Defensa', 'Centrocampista', 'Delantero']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  position = value;
                  setState(() {});
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final number = int.tryParse(numberController.text.trim()) ?? 0;
              if (name.isNotEmpty && number > 0) {
                setState(() {
                  player.name = name;
                  player.number = number;
                  player.position = position;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editMedicalNoteDialog(int index) {
    final player = _players[index];
    final noteController = TextEditingController(text: player.medicalNote ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nota médica'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(hintText: 'Describe la nota médica'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                player.medicalNote = noteController.text.trim().isEmpty ? null : noteController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plantilla del equipo')),
      body: ListView.builder(
        itemCount: _players.length,
        itemBuilder: (context, index) {
          final player = _players[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${player.number}')),
            title: Text(player.name),
            subtitle: Text(player.position),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (player.medicalNote != null && player.medicalNote!.isNotEmpty)
                  const Icon(Icons.medical_services, color: Colors.redAccent, size: 20),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editPlayerDialog(index);
                    } else if (value == 'delete') {
                      _removePlayer(index);
                    } else if (value == 'medical') {
                      _editMedicalNoteDialog(index);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    const PopupMenuItem(value: 'medical', child: Text('Nota médica')),
                    const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlayerDialog,
        child: const Icon(Icons.person_add),
        tooltip: 'Añadir jugador',
      ),
    );
  }
}

