// lib/screens/organizador/partidos_programados_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:intl/intl.dart';

class PartidosProgramadosScreen extends StatefulWidget {
  @override
  _PartidosProgramadosScreenState createState() => _PartidosProgramadosScreenState();
}

class _PartidosProgramadosScreenState extends State<PartidosProgramadosScreen> {
  List<Map<String, dynamic>> partidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  Future<void> _cargarPartidos() async {
    try {
      final response = await ApiService.get('/partidos');
      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          partidos = response.data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print('❌ Error al cargar partidos: $e');
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
        title: Text('Partidos Programados'),
        backgroundColor: Constants.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : partidos.isEmpty
              ? Center(child: Text('No hay partidos programados'))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: partidos.length,
                  itemBuilder: (context, index) {
                    final partido = partidos[index];
                    final fecha = DateTime.tryParse(partido['fecha'] ?? '');
                    final hora = partido['hora'];

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
                                    'Equipo Local: ${partido['equipoLocalNombre'] ?? 'Desconocido'}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Equipo Visitante: ${partido['equipoVisitanteNombre'] ?? 'Desconocido'}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text('Estado: ${partido['estado'] ?? 'Programado'}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}