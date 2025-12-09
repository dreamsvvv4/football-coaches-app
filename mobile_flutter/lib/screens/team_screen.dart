import 'package:flutter/material.dart';
import 'club_form_screen.dart';
import 'team_form_screen.dart';
import 'player_form_screen.dart';

class PlayerItem {
  int number;
  String name;
  String position;
  String? medicalNote;
  String dominantFoot;
  DateTime birthDate;
  String? photoPath;
  String country;
  String countryCode;
  int convocatorias;
  PlayerItem({
    required this.number,
    required this.name,
    required this.position,
    required this.dominantFoot,
    required this.birthDate,
    required this.country,
    required this.countryCode,
    this.photoPath,
    this.medicalNote,
    this.convocatorias = 0,
  });
}

class TeamScreen extends StatefulWidget {
  const TeamScreen({Key? key}) : super(key: key);
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
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
  final List<PlayerItem> _players = List.generate(
    16,
    (i) => PlayerItem(
      number: i + 1,
      name: 'Jugador ${i + 1}',
      position: 'Portero',
      dominantFoot: 'Derecha',
      birthDate: DateTime(2000, 1, 1),
      country: 'España',
      countryCode: 'ES',
    ),
  );

  final String clubName = 'Real Club';

  void _addPlayerDialog() {
    final nameController = TextEditingController();
    final surnameController = TextEditingController();
    final numberController = TextEditingController();
    String position = 'Portero';
    String dominantFoot = 'Derecha';
    DateTime? birthDate;
    String? photoPath;
    final countryController = TextEditingController();
    final countryCodeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir jugador'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: surnameController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
              ),
              TextField(
                    controller: numberController,
                    decoration: const InputDecoration(labelText: 'Número'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: countryController,
                    decoration: const InputDecoration(labelText: 'País'),
                  ),
                  TextField(
                    controller: countryCodeController,
                    decoration: const InputDecoration(labelText: 'Código país (ej: ES, FR, BR)'),
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
                  DropdownButton<String>(
                    value: dominantFoot,
                    items: ['Derecha', 'Izquierda', 'Ambas']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        dominantFoot = value;
                        setState(() {});
                      }
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(birthDate == null
                            ? 'Fecha de nacimiento'
                            : '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2010, 1, 1),
                            firstDate: DateTime(1990),
                            lastDate: DateTime(DateTime.now().year - 4),
                          );
                          if (picked != null) {
                            birthDate = picked;
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(photoPath == null ? 'Sin foto' : 'Foto seleccionada'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo_camera),
                        onPressed: () async {
                          // Aquí iría la lógica de selección de foto (ejemplo con image_picker)
                          // photoPath = await pickImage();
                          // setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final surname = surnameController.text.trim();
                  final number = int.tryParse(numberController.text.trim()) ?? 0;
                  final country = countryController.text.trim();
                  final countryCode = countryCodeController.text.trim().toUpperCase();
                  if (name.isNotEmpty && surname.isNotEmpty && number > 0 && birthDate != null && country.isNotEmpty && countryCode.isNotEmpty) {
                    setState(() {
                      _players.add(PlayerItem(
                        number: number,
                        name: '$name $surname',
                        position: position,
                        dominantFoot: dominantFoot,
                        birthDate: birthDate!,
                        country: country,
                        countryCode: countryCode,
                        photoPath: photoPath,
                        medicalNote: '',
                        convocatorias: 0,
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
    final theme = Theme.of(context);
    // Datos premium de ejemplo
    final String clubLogo = 'https://upload.wikimedia.org/wikipedia/en/5/56/Real_Madrid_CF.svg';
    final String clubCountry = 'España';
    final String clubCountryCode = 'ES';
    final String coachName = 'Carlo Ancelotti';
    final int totalPlayers = _players.length;
    final int avgAge = _players.isNotEmpty
        ? _players.map((p) => DateTime.now().year - p.birthDate.year).reduce((a, b) => a + b) ~/ _players.length
        : 0;
    final int totalMatches = _players.fold(0, (sum, p) => sum + p.convocatorias);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantilla del equipo'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.blueGrey[900],
      ),
      floatingActionButton: _PremiumFab(onAddPlayer: _addPlayerDialog),
      body: Column(
        children: [
          // Cabecera premium
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(clubLogo),
                  radius: 38,
                  backgroundColor: Colors.grey[100],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            clubName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[900],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.network(
                            'https://flagcdn.com/24x18/${clubCountryCode.toLowerCase()}.png',
                            width: 28,
                            height: 20,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Entrenador: $coachName',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blueGrey[700]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatChip(icon: Icons.groups, label: 'Jugadores', value: '$totalPlayers'),
                          const SizedBox(width: 8),
                          _StatChip(icon: Icons.cake, label: 'Edad media', value: '$avgAge'),
                          const SizedBox(width: 8),
                          _StatChip(icon: Icons.sports_soccer, label: 'Partidos', value: '$totalMatches'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Lista de jugadores premium
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _players.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final player = _players[index];
                final now = DateTime.now();
                final age = now.year - player.birthDate.year - ((now.month < player.birthDate.month || (now.month == player.birthDate.month && now.day < player.birthDate.day)) ? 1 : 0);
                final isBirthday = now.month == player.birthDate.month && now.day == player.birthDate.day;
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: Stack(
                      children: [
                        player.photoPath != null
                            ? CircleAvatar(backgroundImage: AssetImage(player.photoPath!), radius: 26)
                            : CircleAvatar(
                                child: Text('${player.number}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                radius: 26,
                                backgroundColor: Colors.blue[50],
                              ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: player.countryCode.isNotEmpty
                              ? SizedBox(
                                  width: 22,
                                  height: 16,
                                  child: Image.network(
                                    'https://flagcdn.com/24x18/${player.countryCode.toLowerCase()}.png',
                                    errorBuilder: (_, __, ___) => const SizedBox(),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Text(player.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        if (isBirthday)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(Icons.cake, color: Colors.pinkAccent, size: 20),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      '${player.position} · ${player.dominantFoot} · Edad: $age · ${player.country} · Partidos: ${player.convocatorias}',
                      style: theme.textTheme.bodyMedium,
                    ),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

class _PremiumFab extends StatelessWidget {
  final VoidCallback onAddPlayer;
  const _PremiumFab({required this.onAddPlayer});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      icon: const Icon(Icons.add),
      label: const Text('Acciones'),
      backgroundColor: Colors.blueAccent,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.sports_soccer, color: Colors.blueAccent),
                  title: const Text('Crear club'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ClubFormScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group, color: Colors.blueAccent),
                  title: const Text('Crear equipo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TeamFormScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add, color: Colors.blueAccent),
                  title: const Text('Añadir jugador'),
                  onTap: () {
                    Navigator.pop(ctx);
                    onAddPlayer();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue[700]),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.blueGrey[700], fontSize: 13)),
        ],
      ),
    );
  }
}




