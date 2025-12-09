import 'package:flutter/material.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, String>> _locations = [
    {'name': 'Estadio Municipal', 'address': 'Av. Principal 123', 'capacity': '5000'},
    {'name': 'Campo San Martín', 'address': 'Calle San Martín 456', 'capacity': '1000'},
  ];

  void _addLocation() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _locations.add({
          'name': _nameController.text,
          'address': _addressController.text,
          'capacity': '0',
        });
      });
      _nameController.clear();
      _addressController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir ubicación'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del campo'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
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
            onPressed: _addLocation,
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubicaciones')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _locations.length,
          itemBuilder: (context, i) {
            final location = _locations[i];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(location['name']!),
                subtitle: Text(location['address']!),
                trailing: IconButton(
                  icon: const Icon(Icons.directions),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Abriendo ubicación: ${location['address']}')),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'locationsFab',
        onPressed: _showAddLocationDialog,
        label: const Text('Añadir Ubicación'),
        icon: const Icon(Icons.add_location),
      ),
    );
  }
}
