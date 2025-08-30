// lib/screens/jugador/seleccionar_torneo_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:torneo_app/utils/helpers.dart'; // ✅ Solo esta importación

class SeleccionarTorneoScreen extends StatefulWidget {
  @override
  _SeleccionarTorneoScreenState createState() => _SeleccionarTorneoScreenState();
}

class _SeleccionarTorneoScreenState extends State<SeleccionarTorneoScreen> {
  List<Map<String, dynamic>> torneos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // ✅ Prueba inmediata
    print('🔧 Prueba: ${capitalize("voleibol")}'); // Debe imprimir "Voleibol"
    _cargarTorneos();
  }

  Future<void> _cargarTorneos() async {
    try {
      final response = await ApiService.get('/torneos');
      print('🔍 Respuesta de /torneos: $response');

      List data = [];

      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map && response.data.containsKey('torneos')) {
        data = response.data['torneos'];
      } else if (response.data is Map && response.data.containsKey('data')) {
        data = response.data['data'];
      }

      setState(() {
        torneos = data.cast<Map<String, dynamic>>();
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
                    final inicio = _parseFecha(torneo['fechaInicio']);
                    final fin = _parseFecha(torneo['fechaFin']);
                    final int maxEquipos = torneo['maxEquipos'] ?? 0;
                    final int equiposRegistrados = torneo['equiposRegistrados'] ?? 0;
                    final int equiposRestantes = maxEquipos - equiposRegistrados;
                    final String? categoria = torneo['categoria'];

                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              torneo['nombre'] ?? 'Sin nombre',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            // ✅ Usa la función global
                            Text('Disciplina: ${capitalize(torneo['disciplina'])}'),
                            Text('Equipos: $equiposRegistrados / $maxEquipos'),
                            if (equiposRestantes > 0)
                              Text('Restantes: $equiposRestantes', style: TextStyle(color: Colors.green))
                            else
                              Text('¡Lleno!', style: TextStyle(color: Colors.red)),
                            Text(
                              'Fechas: ${inicio != null ? DateFormat('dd/MM').format(inicio) : 'Inválida'} - ${fin != null ? DateFormat('dd/MM').format(fin) : 'Inválida'}',
                            ),
                            SizedBox(height: 10),
                            // ✅ Usa la función global
                            if (categoria != null)
                              Text(
                                'Categoría: ${capitalize(categoria)}',
                                style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                              )
                            else
                              Text(
                                'Categoría: No definida',
                                style: TextStyle(color: Colors.orange),
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

  DateTime? _parseFecha(dynamic fecha) {
    if (fecha == null) return null;
    if (fecha is String) {
      return DateTime.tryParse(fecha);
    }
    if (fecha is DateTime) {
      return fecha;
    }
    return null;
  }

  Color _getColorPorEstado(String? estado) {
    switch (estado?.toLowerCase()) {
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