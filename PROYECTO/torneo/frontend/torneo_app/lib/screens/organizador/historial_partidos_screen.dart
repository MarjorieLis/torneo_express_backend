// lib/screens/organizador/historial_partidos_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:intl/intl.dart';

class HistorialPartidosScreen extends StatefulWidget {
  @override
  _HistorialPartidosScreenState createState() => _HistorialPartidosScreenState();
}

class _HistorialPartidosScreenState extends State<HistorialPartidosScreen> {
  List<Map<String, dynamic>> partidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPartidosJugados();
  }

  Future<void> _cargarPartidosJugados() async {
    try {
      final response = await ApiService.get('/partidos');
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data;
        if (data.containsKey('partidos')) {
          setState(() {
            partidos = List<Map<String, dynamic>>.from(data['partidos'])
                .where((p) => p['estado'] == 'jugado')
                .toList();
          });
        }
      } else if (response.data is List) {
        setState(() {
          partidos = response.data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print('❌ Error al cargar historial de partidos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Partidos Jugados'),
        backgroundColor: Constants.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : partidos.isEmpty
              ? Center(child: Text('No hay partidos jugados'))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: partidos.length,
                  itemBuilder: (context, index) {
                    final partido = partidos[index];
                    final fecha = DateTime.tryParse(partido['fecha'] ?? '');
                    final hora = partido['hora'];
                    final disciplina = partido['disciplina'] ?? 'baloncesto';

                    final equipoLocalNombre = partido['equipoLocal'] is Map
                        ? partido['equipoLocal']['nombre'] ?? 'Desconocido'
                        : 'Desconocido';

                    final equipoVisitanteNombre = partido['equipoVisitante'] is Map
                        ? partido['equipoVisitante']['nombre'] ?? 'Desconocido'
                        : 'Desconocido';

                    // ✅ Extraer ganador correctamente
                    String ganador = 'Empate';
                    final ganadorData = partido['resultado']['ganador'];
                    if (ganadorData != null) {
                      final ganadorId = ganadorData['_id'] ?? ganadorData;
                      ganador = ganadorId == partido['equipoLocal']['_id']
                          ? equipoLocalNombre
                          : equipoVisitanteNombre;
                    }

                    final puntosLocal = partido['resultado']['puntosLocal'] ?? 0;
                    final puntosVisitante = partido['resultado']['puntosVisitante'] ?? 0;

                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha: ${fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : 'Inválida'}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('Hora: $hora'),
                            SizedBox(height: 5),
                            Text('Lugar: ${partido['lugar'] ?? 'Cancha Principal'}'),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Equipo Local: $equipoLocalNombre',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Equipo Visitante: $equipoVisitanteNombre',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Resultado: $puntosLocal - $puntosVisitante',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Ganador: $ganador',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Torneo: ${partido['torneo']['nombre'] ?? 'Sin nombre'}',
                              style: TextStyle(color: Colors.purple),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}