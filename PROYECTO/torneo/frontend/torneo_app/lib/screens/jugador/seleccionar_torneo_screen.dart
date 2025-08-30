// lib/screens/jugador/seleccionar_torneo_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:intl/intl.dart';

class SeleccionarTorneoScreen extends StatefulWidget {
  @override
  _SeleccionarTorneoScreenState createState() => _SeleccionarTorneoScreenState();
}

class _SeleccionarTorneoScreenState extends State<SeleccionarTorneoScreen> {
  List torneos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTorneos();
  }

  Future<void> _cargarTorneos() async {
    try {
      final response = await ApiService.get('/torneos');
      setState(() {
        if (response.data is List) {
          torneos = response.data;
        } else if (response.data is Map && response.data.containsKey('data')) {
          torneos = response.data['data'];
        } else {
          torneos = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar torneos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Torneo'),
        backgroundColor: Constants.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : torneos.isEmpty
              ? Center(child: Text('No hay torneos disponibles'))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: torneos.length,
                  itemBuilder: (context, index) {
                    final torneo = torneos[index];
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              torneo['nombre'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('Disciplina: ${torneo['disciplina']}'),
                            Text('Equipos: ${torneo['maxEquipos']}'),
                            Text(
                              'Fechas: ${DateFormat('dd/MM').format(DateTime.parse(torneo['fechaInicio']))} - ${DateFormat('dd/MM').format(DateTime.parse(torneo['fechaFin']))}',
                            ),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getColorPorEstado(torneo['estado']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                torneo['estado'].toUpperCase(),
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            SizedBox(height: 15),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/inscribir_equipo', arguments: torneo);
                              },
                              icon: Icon(Icons.add_circle),
                              label: Text('Inscribir Equipo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constants.primaryColor,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getColorPorEstado(String estado) {
    switch (estado) {
      case 'activo':
        return Colors.green;
      case 'suspendido':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      case 'finalizado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}