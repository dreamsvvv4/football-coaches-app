import 'package:flutter/material.dart';

class PlayerFormScreen extends StatefulWidget {
  const PlayerFormScreen({super.key});

  @override
  State<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends State<PlayerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _birthController = TextEditingController();
  final _dniController = TextEditingController();
  String _gender = 'Masculino';
  final _numberController = TextEditingController();
  String _position = 'Portero';
  String _foot = 'Derecha';
  final _tutorNameController = TextEditingController();
  final _tutorPhoneController = TextEditingController();
  final _tutorEmailController = TextEditingController();
  String? _photoPath;
  String? _medicalFilePath;
  String? _medicalCertPath;
  bool _imagePermission = false;
  final _commentsController = TextEditingController();
  String _status = 'Activo';

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _birthController.dispose();
    _dniController.dispose();
    _numberController.dispose();
    _tutorNameController.dispose();
    _tutorPhoneController.dispose();
    _tutorEmailController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    // TODO: Implementar selección de foto (image_picker)
  }

  Future<void> _pickMedicalFile() async {
    // TODO: Implementar selección de PDF
  }

  Future<void> _pickMedicalCert() async {
    // TODO: Implementar selección de PDF
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Jugador'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Datos personales', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person)),
                        validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _surnameController,
                        decoration: const InputDecoration(labelText: 'Apellidos', prefixIcon: Icon(Icons.person_outline)),
                        validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _birthController,
                        decoration: const InputDecoration(labelText: 'Fecha de nacimiento', prefixIcon: Icon(Icons.cake)),
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2010, 1, 1),
                            firstDate: DateTime(1990),
                            lastDate: DateTime(DateTime.now().year - 4),
                          );
                          if (picked != null) {
                            _birthController.text = '${picked.day}/${picked.month}/${picked.year}';
                          }
                        },
                        validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dniController,
                        decoration: const InputDecoration(labelText: 'DNI/NIE (opcional)', prefixIcon: Icon(Icons.badge)),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        items: const [
                          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                          DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                          DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                        ],
                        onChanged: (v) => setState(() => _gender = v ?? 'Masculino'),
                        decoration: const InputDecoration(labelText: 'Género'),
                      ),
                      const SizedBox(height: 24),
                      Text('Información deportiva', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _numberController,
                        decoration: const InputDecoration(labelText: 'Dorsal', prefixIcon: Icon(Icons.numbers)),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _position,
                        items: const [
                          DropdownMenuItem(value: 'Portero', child: Text('Portero')),
                          DropdownMenuItem(value: 'Defensa', child: Text('Defensa')),
                          DropdownMenuItem(value: 'Centrocampista', child: Text('Centrocampista')),
                          DropdownMenuItem(value: 'Delantero', child: Text('Delantero')),
                        ],
                        onChanged: (v) => setState(() => _position = v ?? 'Portero'),
                        decoration: const InputDecoration(labelText: 'Posición'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _foot,
                        items: const [
                          DropdownMenuItem(value: 'Derecha', child: Text('Derecha')),
                          DropdownMenuItem(value: 'Izquierda', child: Text('Izquierda')),
                          DropdownMenuItem(value: 'Ambas', child: Text('Ambas')),
                        ],
                        onChanged: (v) => setState(() => _foot = v ?? 'Derecha'),
                        decoration: const InputDecoration(labelText: 'Pierna dominante'),
                      ),
                      const SizedBox(height: 24),
                      Text('Contacto', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tutorNameController,
                        decoration: const InputDecoration(labelText: 'Nombre del tutor', prefixIcon: Icon(Icons.person)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tutorPhoneController,
                        decoration: const InputDecoration(labelText: 'Teléfono del tutor', prefixIcon: Icon(Icons.phone)),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tutorEmailController,
                        decoration: const InputDecoration(labelText: 'Email del tutor', prefixIcon: Icon(Icons.email)),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      Text('Documentación', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: _photoPath == null ? const Icon(Icons.photo_camera) : Image.asset(_photoPath!, width: 24, height: 24),
                              label: Text(_photoPath == null ? 'Foto del jugador' : 'Cambiar foto'),
                              onPressed: _pickPhoto,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.picture_as_pdf),
                              label: Text(_medicalFilePath == null ? 'Ficha médica (opcional)' : 'Cambiar ficha médica'),
                              onPressed: _pickMedicalFile,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.picture_as_pdf_outlined),
                              label: Text(_medicalCertPath == null ? 'Certificado médico (opcional)' : 'Cambiar certificado'),
                              onPressed: _pickMedicalCert,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        value: _imagePermission,
                        onChanged: (v) => setState(() => _imagePermission = v ?? false),
                        title: const Text('Permiso imágenes menores'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 24),
                      Text('Extras', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _commentsController,
                        decoration: const InputDecoration(labelText: 'Comentarios internos del staff', prefixIcon: Icon(Icons.comment)),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _status,
                        items: const [
                          DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                          DropdownMenuItem(value: 'Lesionado', child: Text('Lesionado')),
                          DropdownMenuItem(value: 'Baja temporal', child: Text('Baja temporal')),
                        ],
                        onChanged: (v) => setState(() => _status = v ?? 'Activo'),
                        decoration: const InputDecoration(labelText: 'Estado del jugador'),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Crear jugador'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() == true) {
                            // TODO: Guardar jugador premium
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
