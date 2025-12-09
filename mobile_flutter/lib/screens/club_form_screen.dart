import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClubFormScreen extends StatefulWidget {
  const ClubFormScreen({super.key});

  @override
  State<ClubFormScreen> createState() => _ClubFormScreenState();
}

class _ClubFormScreenState extends State<ClubFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _crestUrlController = TextEditingController();
  final _primaryColorController = TextEditingController();
  final _secondaryColorController = TextEditingController();
  final _foundedYearController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _gpsController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _presidentController = TextEditingController();
  final _presidentPhoneController = TextEditingController();
  final _presidentEmailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _xController = TextEditingController();
  bool _privacyAccepted = false;
  String? _crestPath;
  Color? _primaryColor;
  Color? _secondaryColor;

  @override
  void dispose() {
    _nameController.dispose();
    _crestUrlController.dispose();
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    _foundedYearController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _gpsController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _presidentController.dispose();
    _presidentPhoneController.dispose();
    _presidentEmailController.dispose();
    _descriptionController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _xController.dispose();
    super.dispose();
  }

  Future<void> _pickCrest() async {
    // TODO: Implementar selección de imagen (image_picker)
  }

  Future<void> _pickColor(bool primary) async {
    // TODO: Implementar selector de color premium
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Club'),
        backgroundColor: _primaryColor ?? theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _primaryColor ?? theme.colorScheme.primary,
              _secondaryColor ?? theme.colorScheme.secondary,
            ],
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
                      Text('Identidad del club', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre del club', prefixIcon: Icon(Icons.flag)),
                        validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: _crestPath == null ? const Icon(Icons.image) : Image.asset(_crestPath!, width: 24, height: 24),
                              label: Text(_crestPath == null ? 'Subir escudo/logo' : 'Cambiar escudo'),
                              onPressed: _pickCrest,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.color_lens),
                              label: Text(_primaryColor == null ? 'Color primario' : 'Cambiar color primario'),
                              onPressed: () => _pickColor(true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.color_lens_outlined),
                              label: Text(_secondaryColor == null ? 'Color secundario' : 'Cambiar color secundario'),
                              onPressed: () => _pickColor(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _foundedYearController,
                        decoration: const InputDecoration(labelText: 'Año de fundación (opcional)', prefixIcon: Icon(Icons.calendar_today)),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 24),
                      Text('Información general', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'Localidad / Ciudad', prefixIcon: Icon(Icons.location_city)),
                        validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _regionController,
                        decoration: const InputDecoration(labelText: 'Provincia / Región'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _countryController,
                        decoration: const InputDecoration(labelText: 'País', prefixIcon: Icon(Icons.flag_circle)),
                        validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Dirección del campo principal', prefixIcon: Icon(Icons.sports_soccer)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _gpsController,
                        decoration: const InputDecoration(labelText: 'Coordenadas GPS (auto desde mapa)', prefixIcon: Icon(Icons.map)),
                        readOnly: true,
                        onTap: () {
                          // TODO: Abrir selector de mapa premium
                        },
                      ),
                      const SizedBox(height: 24),
                      Text('Contacto', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Teléfono del club', prefixIcon: Icon(Icons.phone)),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email oficial', prefixIcon: Icon(Icons.email)),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(labelText: 'Página web (opcional)', prefixIcon: Icon(Icons.web)),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 24),
                      Text('Administración', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _presidentController,
                        decoration: const InputDecoration(labelText: 'Presidente / Coordinador', prefixIcon: Icon(Icons.person)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _presidentPhoneController,
                        decoration: const InputDecoration(labelText: 'Teléfono de contacto', prefixIcon: Icon(Icons.phone_android)),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _presidentEmailController,
                        decoration: const InputDecoration(labelText: 'Email de contacto', prefixIcon: Icon(Icons.email_outlined)),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      Text('Opciones adicionales', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Descripción del club', prefixIcon: Icon(Icons.info)),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _instagramController,
                              decoration: const InputDecoration(labelText: 'Instagram', prefixIcon: Icon(Icons.camera_alt)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _facebookController,
                              decoration: const InputDecoration(labelText: 'Facebook', prefixIcon: Icon(Icons.facebook)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _xController,
                              decoration: const InputDecoration(labelText: 'X (Twitter)', prefixIcon: Icon(Icons.alternate_email)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _privacyAccepted,
                        onChanged: (v) => setState(() => _privacyAccepted = v ?? false),
                        title: const Text('Acepto la política de privacidad y permisos para menores'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Crear club'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          backgroundColor: _primaryColor ?? theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() == true && _privacyAccepted) {
                            // TODO: Guardar club premium
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
