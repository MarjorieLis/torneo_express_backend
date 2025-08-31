// lib/screens/organizador/detalle_equipo_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:torneo_app/utils/helpers.dart';

class DetalleEquipoScreen extends StatelessWidget {
  final Map<String, dynamic> equipo;

  const DetalleEquipoScreen({super.key, required this.equipo});

  @override
  Widget build(BuildContext context) {
    final capitan = equipo['capitán'];
    final nombreCapitan = capitan?['nombre'] ?? 'Sin nombre';
    final cedulaCapitan = equipo['cedulaCapitan'];
    final jugadores = List<Map<String, dynamic>>.from(equipo['jugadores'] ?? []);

    final totalJugadores = jugadores.length + 1; // +1 por capitán
    final minJugadores = _getMinJugadores(equipo['disciplina']);
    final maxJugadores = _getMaxJugadores(equipo['disciplina']);
    final cumpleReglas = totalJugadores >= minJugadores && totalJugadores <= maxJugadores;
    final capitanEnLista = jugadores.any((j) => j['cedula'] == cedulaCapitan);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Equipo'),
        backgroundColor: Constants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información principal
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipo['nombre'] ?? 'Sin nombre',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Disciplina: ${capitalize(equipo['disciplina'])}'),
                    Text('Estado: ${capitalize(equipo['estado'])}'),
                    Text('Cédula del capitán: $cedulaCapitan'),
                    Text('Nombre del capitán: $nombreCapitan'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Validaciones
            Card(
              color: cumpleReglas ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      cumpleReglas ? Icons.check_circle : Icons.warning,
                      color: cumpleReglas ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cumpleReglas
                            ? '✅ Cantidad de jugadores válida ($totalJugadores/$maxJugadores)'
                            : '❌ Debe tener entre $minJugadores y $maxJugadores jugadores',
                        style: TextStyle(color: cumpleReglas ? Colors.green[800] : Colors.red[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 8),

            Card(
              color: capitanEnLista ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      capitanEnLista ? Icons.check_circle : Icons.warning,
                      color: capitanEnLista ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        capitanEnLista
                            ? '✅ El capitán está en la lista de jugadores'
                            : '❌ El capitán no está en la lista de jugadores',
                        style: TextStyle(color: capitanEnLista ? Colors.green[800] : Colors.red[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Lista de jugadores
            Text(
              'Jugadores (${jugadores.length}):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: jugadores.length,
                itemBuilder: (context, index) {
                  final jugador = jugadores[index];
                  final esCapitan = jugador['cedula'] == cedulaCapitan;
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('${jugador['nombre']} - ${jugador['cedula']}'),
                          ),
                          if (esCapitan)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Capitán',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
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
      ),
    );
  }

  int _getMinJugadores(String? disciplina) {
    switch (disciplina?.toLowerCase()) {
      case 'fútbol':
        return 11;
      case 'baloncesto':
        return 5;
      case 'voleibol':
        return 6;
      case 'tenis':
        return 1;
      default:
        return 1;
    }
  }

  int _getMaxJugadores(String? disciplina) {
    switch (disciplina?.toLowerCase()) {
      case 'fútbol':
        return 18;
      case 'baloncesto':
        return 12;
      case 'voleibol':
        return 12;
      case 'tenis':
        return 2;
      default:
        return 15;
    }
  }
}