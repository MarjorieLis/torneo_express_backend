// lib/screens/jugador/calendario_jugador_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:intl/intl.dart';

class CalendarioJugadorScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const CalendarioJugadorScreen({super.key, required this.user});

  @override
  _CalendarioJugadorScreenState createState() => _CalendarioJugadorScreenState();
}

class _CalendarioJugadorScreenState extends State<CalendarioJugadorScreen> {
  List<Map<String, dynamic>> partidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  Future<void> _cargarPartidos() async {
    try {
      final response = await ApiService.get('/partidos/jugador/${widget.user['cedula']}');
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data;
        if (data.containsKey('partidos')) {
          setState(() {
            partidos = List<Map<String, dynamic>>.from(data['partidos']);
          });
        }
      } else if (response.data is List) {
        setState(() {
          partidos = response.data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print('❌ Error al cargar calendario: $e');
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
        title: Text('Mi Calendario'),
        backgroundColor: Constants.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : partidos.isEmpty
              ? Center(child: Text('No tienes partidos programados'))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: partidos.length,
                  itemBuilder: (context, index) {
                    final partido = partidos[index];
                    final fecha = DateTime.tryParse(partido['fecha'] ?? '');
                    final hora = partido['hora'];

                    final equipoLocalNombre = partido['equipoLocal'] is Map
                        ? partido['equipoLocal']['nombre'] ?? 'Desconocido'
                        : 'Desconocido';

                    final equipoVisitanteNombre = partido['equipoVisitante'] is Map
                        ? partido['equipoVisitante']['nombre'] ?? 'Desconocido'
                        : 'Desconocido';

                    // Determinar si el jugador está en el equipo local o visitante
                    final esEquipoLocal = partido['equipoLocal']['_id'] == widget.user['equipoId'];
                    final miEquipo = esEquipoLocal ? equipoLocalNombre : equipoVisitanteNombre;
                    final rival = esEquipoLocal ? equipoVisitanteNombre : equipoLocalNombre;

                    // Resultado
                    final puntosLocal = partido['resultado']['puntosLocal'] ?? 0;
                    final puntosVisitante = partido['resultado']['puntosVisitante'] ?? 0;

                    // ✅ Determinar si mi equipo ganó basado en el ganador guardado
                    bool? ganoMiEquipo;
                    if (partido['estado'] == 'jugado') {
                      final ganadorId = partido['resultado']['ganador']?['_id'];
                      if (ganadorId != null) {
                        ganoMiEquipo = ganadorId == widget.user['equipoId'];
                      } else {
                        ganoMiEquipo = null; // Empate
                      }
                    }

                    return Card(
                      color: ganoMiEquipo == true
                          ? Colors.green[50]
                          : ganoMiEquipo == false
                              ? Colors.red[50]
                              : null,
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
                            Text(
                              'Torneo: ${partido['torneo']['nombre'] ?? 'Sin nombre'}',
                              style: TextStyle(color: Colors.purple),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Mi equipo: $miEquipo',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Constants.primaryColor),
                            ),
                            Text(
                              'Rival: $rival',
                              style: TextStyle(color: Colors.orange),
                            ),
                            SizedBox(height: 10),
                            if (partido['estado'] == 'jugado')
                              Column(
                                children: [
                                  Text(
                                    'Resultado: $puntosLocal - $puntosVisitante',
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    ganoMiEquipo == true
                                        ? '✅ ¡Ganamos!'
                                        : ganoMiEquipo == false
                                            ? '❌ Perdimos'
                                            : '🤝 Empate',
                                    style: TextStyle(
                                      color: ganoMiEquipo == true
                                          ? Colors.blue
                                          : ganoMiEquipo == false
                                              ? Colors.red
                                              : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                'Estado: Programado',
                                style: TextStyle(color: Colors.grey),
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