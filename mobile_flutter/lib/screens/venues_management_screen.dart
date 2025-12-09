import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../services/venue_service.dart';
import '../services/auth_service.dart';

class VenuesManagementScreen extends StatefulWidget {
  const VenuesManagementScreen({Key? key}) : super(key: key);

  @override
  State<VenuesManagementScreen> createState() => _VenuesManagementScreenState();
}

class _VenuesManagementScreenState extends State<VenuesManagementScreen> {
  late List<Venue> _venues;
  late List<Venue> _filteredVenues;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _venues = VenueService.instance.getAllVenues();
    _filteredVenues = _venues;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Check if user can manage venues (RBAC)
  bool get _canManageVenues {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;
    final allowedRoles = {'coach', 'club_admin', 'superadmin'};
    return allowedRoles.contains(user.role);
  }

  void _filterVenues(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVenues = _venues;
      } else {
        _filteredVenues = VenueService.instance.searchByName(query);
      }
    });
  }

  Future<void> _showAddVenueDialog() async {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lonCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Recinto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del recinto',
                  hintText: 'Ej: Campo Municipal Centro',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  hintText: 'Ej: Calle Principal 123',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: latCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Latitud',
                  hintText: '40.4168',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lonCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Longitud',
                  hintText: '-3.7038',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ej: 2 pistas de fútbol 7',
                ),
                maxLines: 2,
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
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final address = addressCtrl.text.trim();
              final lat = double.tryParse(latCtrl.text.trim());
              final lon = double.tryParse(lonCtrl.text.trim());
              final description = descCtrl.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El nombre es requerido')),
                );
                return;
              }

              if (lat == null || lon == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coordenadas inválidas')),
                );
                return;
              }

              try {
                await VenueService.instance.createVenue(
                  name: name,
                  latitude: lat,
                  longitude: lon,
                  address: address.isEmpty ? null : address,
                  description: description.isEmpty ? null : description,
                );

                if (!mounted) return;
                setState(() {
                  _venues = VenueService.instance.getAllVenues();
                  _filteredVenues = _venues;
                  _searchController.clear();
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recinto creado exitosamente')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditVenueDialog(Venue venue) async {
    final nameCtrl = TextEditingController(text: venue.name);
    final addressCtrl = TextEditingController(text: venue.address ?? '');
    final latCtrl = TextEditingController(text: venue.latitude.toString());
    final lonCtrl = TextEditingController(text: venue.longitude.toString());
    final descCtrl = TextEditingController(text: venue.description ?? '');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Recinto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del recinto'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: latCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Latitud'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lonCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Longitud'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
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
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final address = addressCtrl.text.trim();
              final lat = double.tryParse(latCtrl.text.trim());
              final lon = double.tryParse(lonCtrl.text.trim());
              final description = descCtrl.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El nombre es requerido')),
                );
                return;
              }

              if (lat == null || lon == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coordenadas inválidas')),
                );
                return;
              }

              try {
                await VenueService.instance.updateVenue(
                  id: venue.id,
                  name: name,
                  latitude: lat,
                  longitude: lon,
                  address: address.isEmpty ? null : address,
                  description: description.isEmpty ? null : description,
                );

                if (!mounted) return;
                setState(() {
                  _venues = VenueService.instance.getAllVenues();
                  _filteredVenues = _venues;
                  _searchController.clear();
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recinto actualizado')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVenue(String venueId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Recinto'),
        content: const Text('¿Estás seguro que deseas eliminar este recinto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await VenueService.instance.deleteVenue(venueId);
      if (!mounted) return;
      setState(() {
        _venues = VenueService.instance.getAllVenues();
        _filteredVenues = _venues;
        _searchController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recinto eliminado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Recintos'),
      ),
      body: _buildBody(),
      floatingActionButton: _canManageVenues
          ? FloatingActionButton.extended(
              onPressed: _showAddVenueDialog,
              icon: const Icon(Icons.add_location),
              label: const Text('Nuevo Recinto'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (!_canManageVenues) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes permisos para gestionar recintos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Solo entrenadores, administradores de club y superadministradores pueden hacerlo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filterVenues,
            decoration: InputDecoration(
              hintText: 'Buscar recintos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterVenues('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: _filteredVenues.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sin recintos',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crea tu primer recinto con el botón +',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredVenues.length,
                  itemBuilder: (context, index) {
                    final venue = _filteredVenues[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Card(
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(
                            venue.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (venue.address != null) ...[
                                const SizedBox(height: 4),
                                Text(venue.address!),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                '${venue.latitude.toStringAsFixed(4)}, ${venue.longitude.toStringAsFixed(4)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).disabledColor,
                                    ),
                              ),
                              if (venue.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  venue.description!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Text('Editar'),
                                onTap: () => _showEditVenueDialog(venue),
                              ),
                              PopupMenuItem(
                                child: const Text('Eliminar'),
                                onTap: () => _deleteVenue(venue.id),
                              ),
                            ],
                          ),
                          isThreeLine: venue.address != null || venue.description != null,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
