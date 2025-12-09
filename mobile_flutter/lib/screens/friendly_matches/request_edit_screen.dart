import 'package:flutter/material.dart';
import '../../../models/friendly_match_request.dart';
import '../../../services/friendly_match_service_premium.dart';

class RequestEditScreen extends StatefulWidget {
  const RequestEditScreen({super.key});

  @override
  State<RequestEditScreen> createState() => _RequestEditScreenState();
}

class _RequestEditScreenState extends State<RequestEditScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;
  String? _location;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final req = ModalRoute.of(context)!.settings.arguments as FriendlyMatchRequest;
    _date ??= req.proposedDate;
    _location ??= req.proposedLocation;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(useMaterial3: true), child: child!),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    _formKey.currentState!.save();
    final req = ModalRoute.of(context)!.settings.arguments as FriendlyMatchRequest;
    await FriendlyMatchService.instance.updateRequestProposal(req.id, _date!, _location!);
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Propuesta enviada')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Proponer nueva fecha')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: _date == null ? '' : '${_date!.day}/${_date!.month}/${_date!.year}'),
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: 'Nueva fecha',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (_) => _date == null ? 'Selecciona una fecha' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _location,
                  decoration: const InputDecoration(labelText: 'Nuevo lugar', border: OutlineInputBorder()),
                  onSaved: (v) => _location = v,
                  validator: (v) => (v == null || v.isEmpty) ? 'Indica el lugar' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Enviar nueva propuesta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  onPressed: _loading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
