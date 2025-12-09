import 'package:flutter/material.dart';
import '../services/agenda_service.dart';
import 'team_screen.dart';

class ConvocatoriaFlowScreen extends StatefulWidget {
  const ConvocatoriaFlowScreen({Key? key}) : super(key: key);

  @override
  State<ConvocatoriaFlowScreen> createState() => _ConvocatoriaFlowScreenState();
}

class _ConvocatoriaFlowScreenState extends State<ConvocatoriaFlowScreen> {
  int _step = 0;
  AgendaItem? _selectedMatch;
  List<int> _selectedPlayers = [];
  bool _sending = false;

  void _nextStep() {
    setState(() {
      if (_step < 2) _step++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_step > 0) _step--;
    });
  }

  Future<List<AgendaItem>> _fetchMatches() async {
    final agenda = await AgendaService.instance.getUpcoming();
    return agenda.where((e) => e.matchId != null).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva convocatoria')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _nextStep,
        onStepCancel: _prevStep,
        steps: [
          Step(
            title: const Text('Selecciona partido'),
            content: FutureBuilder<List<AgendaItem>>(
              future: _fetchMatches(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final matches = snapshot.data ?? [];
                if (matches.isEmpty) {
                  return const Text('No hay partidos disponibles');
                }
                return Column(
                  children: matches.map((match) {
                    final selected = _selectedMatch?.id == match.id;
                    return ListTile(
                      title: Text(match.title),
                      subtitle: Text('${match.when}'),
                      selected: selected,
                      trailing: selected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                      onTap: () {
                        setState(() {
                          _selectedMatch = match;
                        });
                        _nextStep();
                      },
                    );
                  }).toList(),
                );
              },
            ),
            isActive: _step == 0,
            state: _selectedMatch != null ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Selecciona jugadores'),
            content: TeamStep(
              selectedPlayers: _selectedPlayers,
              onSelectionChanged: (list) {
                setState(() {
                  _selectedPlayers = list;
                });
              },
            ),
            isActive: _step == 1,
            state: _selectedPlayers.isNotEmpty ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Resumen y enviar'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Partido: ${_selectedMatch?.title ?? "No seleccionado"}'),
                Text('Fecha: ${_selectedMatch != null ? _selectedMatch!.when.toString() : "No seleccionada"}'),
                Text('Jugadores: ${_selectedPlayers.length} seleccionados'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectedMatch != null && _selectedPlayers.isNotEmpty && !_sending
                      ? () async {
                          setState(() => _sending = true);
                          await Future.delayed(const Duration(seconds: 1)); // Simula envío
                          setState(() => _sending = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Convocatoria enviada')),
                          );
                        }
                      : null,
                  child: _sending ? const CircularProgressIndicator() : const Text('Enviar convocatoria'),
                ),
              ],
            ),
            isActive: _step == 2,
          ),
        ],
      ),
    );
  }
}

class TeamStep extends StatelessWidget {
  final List<int> selectedPlayers;
  final void Function(List<int>) onSelectionChanged;
  const TeamStep({required this.selectedPlayers, required this.onSelectionChanged, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simulación: lista de 16 jugadores
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: 16,
        itemBuilder: (context, index) {
          final selected = selectedPlayers.contains(index);
          return CheckboxListTile(
            value: selected,
            title: Text('Jugador ${index + 1}'),
            onChanged: (v) {
              final newList = List<int>.from(selectedPlayers);
              if (v == true) {
                newList.add(index);
              } else {
                newList.remove(index);
              }
              onSelectionChanged(newList);
            },
          );
        },
      ),
    );
  }
}
