import 'package:flutter/material.dart';
import '../models/club.dart';
import '../services/club_registry.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final List<Club> _clubs = [
    Club(
      id: 'club1',
      name: 'Real Madrid CF',
      city: 'Madrid',
      country: 'España',
      crestUrl: null,
      description: 'El club más exitoso de Europa',
      foundedYear: 1902,
    ),
    Club(
      id: 'club2',
      name: 'FC Barcelona',
      city: 'Barcelona',
      country: 'España',
      crestUrl: null,
      description: 'Equipo histórico catalán',
      foundedYear: 1899,
    ),
    Club(
      id: 'club3',
      name: 'Atlético Madrid',
      city: 'Madrid',
      country: 'España',
      crestUrl: null,
      description: 'Club rival del Real Madrid',
      foundedYear: 1903,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Register demo clubs globally
    ClubRegistry.clubs = _clubs;
  }

  void _editClub(Club club) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClubEditScreen(club: club, onSave: (updated) {
          setState(() {
            final index = _clubs.indexWhere((c) => c.id == updated.id);
            if (index >= 0) {
              _clubs[index] = updated;
            }
          });
        }),
      ),
    );
  }

  void _deleteClub(Club club) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar club'),
        content: Text('¿Estás seguro de que quieres eliminar ${club.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _clubs.removeWhere((c) => c.id == club.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${club.name} eliminado')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Clubes'),
        elevation: 0,
      ),
      body: _clubs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes clubes aún',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _clubs.length,
              itemBuilder: (context, index) {
                final club = _clubs[index];
                return ClubCard(
                  club: club,
                  onEdit: () => _editClub(club),
                  onDelete: () => _deleteClub(club),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'clubsFab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClubEditScreen(
                club: null,
                onSave: (newClub) {
                  setState(() => _clubs.add(newClub));
                },
              ),
            ),
          );
        },
        tooltip: 'Nuevo club',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ClubCard extends StatelessWidget {
  final Club club;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClubCard({
    required this.club,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (club.crestUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                club.crestUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(102),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.sports_soccer,
                  size: 64,
                  color: Colors.white.withAlpha(127),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (club.city != null || club.country != null)
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        [club.city, club.country].whereType<String>().join(', '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                if (club.foundedYear != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Fundado: ${club.foundedYear}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),
                if (club.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      club.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClubEditScreen extends StatefulWidget {
  final Club? club;
  final Function(Club) onSave;

  const ClubEditScreen({required this.club, required this.onSave, super.key});

  @override
  State<ClubEditScreen> createState() => _ClubEditScreenState();
}

class _ClubEditScreenState extends State<ClubEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _descriptionController;
  late TextEditingController _yearController;
  String? _photoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.club?.name ?? '');
    _cityController = TextEditingController(text: widget.club?.city ?? '');
    _countryController = TextEditingController(text: widget.club?.country ?? '');
    _descriptionController = TextEditingController(text: widget.club?.description ?? '');
    _yearController = TextEditingController(text: widget.club?.foundedYear?.toString() ?? '');
    _photoUrl = widget.club?.crestUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _pickPhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa la URL de la foto del club:'),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'https://...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => _photoUrl = value.isEmpty ? null : value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _saveClub() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del club es requerido')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final club = Club(
        id: widget.club?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        city: _cityController.text.isEmpty ? null : _cityController.text,
        country: _countryController.text.isEmpty ? null : _countryController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        foundedYear: _yearController.text.isEmpty ? null : int.tryParse(_yearController.text),
        crestUrl: _photoUrl,
      );

      widget.onSave(club);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${club.name} guardado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club == null ? 'Nuevo Club' : 'Editar ${widget.club!.name}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto del club
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(102),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _photoUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_camera, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            'Toca para agregar foto',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Nombre
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del club *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.sports_soccer),
              ),
            ),
            const SizedBox(height: 16),

            // Ciudad
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Ciudad',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 16),

            // País
            TextField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: 'País',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.public),
              ),
            ),
            const SizedBox(height: 16),

            // Año de fundación
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Año de fundación',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),

            // Descripción
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveClub,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar Club'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
