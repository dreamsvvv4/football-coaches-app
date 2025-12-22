import 'package:flutter/material.dart';
import '../models/club.dart';
import '../models/player.dart';
import '../services/permission_service.dart';
import '../models/permissions.dart';
import '../services/auth_service.dart';
import 'club_form_screen.dart';
import 'team_form_screen.dart';
import 'player_form_screen.dart';

class TeamScreen extends StatefulWidget {
  final Club club;
  const TeamScreen({Key? key, required this.club}) : super(key: key);
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<Player> _players = [];

  // Controllers and state for add/edit dialogs
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  String position = 'Centrocampista';
  String dominantFoot = 'Derecha';
  DateTime? birthDate;
  String? photoPath;

  void _addPlayerDialog() {
    nameController.clear();
    surnameController.clear();
    numberController.clear();
    countryController.clear();
    countryCodeController.clear();
    position = 'Centrocampista';
    dominantFoot = 'Derecha';
    birthDate = null;
    photoPath = null;
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
                    setState(() {
                      position = value;
                    });
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
                    setState(() {
                      dominantFoot = value;
                    });
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
                        setState(() {
                          birthDate = picked;
                        });
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
                      // TODO: Implement photo picker
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
                  _players.add(Player(
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
  void _editPlayerDialog(int index) {
    final player = _players[index];
    nameController.text = player.name;
    surnameController.text = '';
    numberController.text = player.number.toString();
    countryController.text = player.country;
    countryCodeController.text = player.countryCode;
    position = player.position;
    dominantFoot = player.dominantFoot;
    birthDate = player.birthDate;
    photoPath = player.photoPath;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar jugador'),
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
                    setState(() {
                      position = value;
                    });
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
                    setState(() {
                      dominantFoot = value;
                    });
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
                        initialDate: birthDate ?? DateTime(2010, 1, 1),
                        firstDate: DateTime(1990),
                        lastDate: DateTime(DateTime.now().year - 4),
                      );
                      if (picked != null) {
                        setState(() {
                          birthDate = picked;
                        });
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
                      // TODO: Implement photo picker
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
              if (name.isNotEmpty && number > 0 && birthDate != null && country.isNotEmpty && countryCode.isNotEmpty) {
                setState(() {
                  _players[index] = Player(
                    number: number,
                    name: name,
                    position: position,
                    dominantFoot: dominantFoot,
                    birthDate: birthDate!,
                    country: country,
                    countryCode: countryCode,
                    photoPath: photoPath,
                    medicalNote: player.medicalNote,
                    convocatorias: player.convocatorias,
                  );
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

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Datos premium de ejemplo

    final String? clubLogoUrl = (widget.club.crestUrl?.isNotEmpty == true)
      ? widget.club.crestUrl
      : null;
    final String clubName = widget.club.name;
    final String clubCountry = widget.club.country ?? '';
    final String clubCountryCode = (widget.club.country ?? 'ES').substring(0, 2).toUpperCase();
    final String coachName = 'Carlo Ancelotti'; // TODO: Hacer dinámico si tienes datos de entrenador
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
                  radius: 38,
                  backgroundColor: Colors.grey[100],
                  child: ClipOval(
                    child: clubLogoUrl == null
                        ? Icon(Icons.shield_outlined, size: 42, color: Colors.blueGrey[300])
                        : Image.network(
                            clubLogoUrl,
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.shield_outlined, size: 42, color: Colors.blueGrey[300]),
                          ),
                  ),
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




