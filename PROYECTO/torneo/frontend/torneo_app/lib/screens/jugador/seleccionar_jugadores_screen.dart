// lib/screens/jugador/seleccionar_jugadores_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';

class SeleccionarJugadoresScreen extends StatefulWidget {
  final String disciplina;
  final String cedulaCapitan;

  const SeleccionarJugadoresScreen({super.key, required this.disciplina, required this.cedulaCapitan});

  @override
  _SeleccionarJugadoresScreenState createState() => _SeleccionarJugadoresScreenState();
}

class _SeleccionarJugadoresScreenState extends State<SeleccionarJugadoresScreen> {
  List<Map<String, dynamic>> jugadores = [];
  bool _isLoading = true;
  List<String> _jugadoresSeleccionados = [];

  @override
  void initState() {
    super.initState();
    _cargarJugadores();
  }

  Future<void> _cargarJugadores() async {
  try {
    // ✅ CORREGIDO: Añade '/api' antes de '/jugadores'
    final response = await ApiService.get('/api/jugadores');

    setState(() {
      if (response.data is List) {
        jugadores = List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map && response.data.containsKey('data')) {
        jugadores = List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        jugadores = [];
      }
      _isLoading = false;
    });
  } on Exception catch (e) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar jugadores: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Jugadores'),
        backgroundColor: Constants.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: jugadores.length,
              itemBuilder: (context, index) {
                final jugador = jugadores[index];
                final id = jugador['_id'] ?? '';
                final isSelected = _jugadoresSeleccionados.contains(id);
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue,
                    child: Text((jugador['name'] ?? 'J')[0].toUpperCase()),
                  ),
                  title: Text(jugador['name'] ?? 'Sin nombre'),
                  subtitle: Text('Posición: ${jugador['position'] ?? 'N/A'}'),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _jugadoresSeleccionados.add(id);
                        } else {
                          _jugadoresSeleccionados.remove(id);
                        }
                      });
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Constants.primaryColor,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context, _jugadoresSeleccionados);
          },
          icon: Icon(Icons.check, color: Constants.primaryColor),
          label: Text('Confirmar', style: TextStyle(color: Constants.primaryColor)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}