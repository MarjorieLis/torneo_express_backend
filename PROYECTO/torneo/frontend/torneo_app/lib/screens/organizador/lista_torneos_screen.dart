// lib/screens/organizador/lista_torneos_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:intl/intl.dart';
import 'detalle_torneo_screen.dart';

class ListaTorneosScreen extends StatefulWidget {
  @override
  _ListaTorneosScreenState createState() => _ListaTorneosScreenState();
}

class _ListaTorneosScreenState extends State<ListaTorneosScreen> {
  List torneos = [];
  bool _isLoading = true;
  final DateFormat _formatoFecha = DateFormat('dd/MM/yyyy');

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
        } else if (response.data is Map && response.data.containsKey('torneos')) {
          torneos = response.data['torneos'];
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

  Future<void> _suspenderTorneo(String? id) async {
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ID del torneo no válido')),
      );
      return;
    }

    try {
      print('🆔 Intentando suspender torneo: $id');
      final response = await ApiService.put('/torneos/$id/suspender', {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Torneo suspendido')),
      );
      _cargarTorneos();
    } on Exception catch (e) {
      print('❌ Error al suspender: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al suspender: $e')),
      );
    }
  }

  Future<void> _cancelarTorneo(String? id) async {
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ID del torneo no válido')),
      );
      return;
    }

    try {
      print('🆔 Intentando cancelar torneo: $id');
      final response = await ApiService.put('/torneos/$id/cancelar', {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Torneo cancelado')),
      );
      _cargarTorneos();
    } on Exception catch (e) {
      print('❌ Error al cancelar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al cancelar: $e')),
      );
    }
  }

  Future<void> _reanudarTorneo(String? id) async {
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ID del torneo no válido')),
      );
      return;
    }

    try {
      print('🆔 Intentando reanudar torneo: $id');
      final response = await ApiService.put('/torneos/$id/reanudar', {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Torneo reanudado')),
      );
      _cargarTorneos();
    } on Exception catch (e) {
      print('❌ Error al reanudar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al reanudar: $e')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Torneos'),
        backgroundColor: Constants.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : torneos.isEmpty
              ? Center(child: Text('No has creado torneos'))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: torneos.length,
                  itemBuilder: (context, index) {
                    final torneo = torneos[index];
                    final String? id = torneo['_id'] ?? torneo['id'];
                    final String estado = torneo['estado'] ?? 'activo';

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              torneo['nombre'] ?? 'Sin nombre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              (torneo['disciplina'] ?? '').toUpperCase(),
                              style: TextStyle(color: Constants.primaryColor),
                            ),
                            Text(
                              '${_formatoFecha.format(DateTime.parse(torneo['fechaInicio']))} - ${_formatoFecha.format(DateTime.parse(torneo['fechaFin']))}',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getColorPorEstado(estado),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    estado.toUpperCase(),
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                Spacer(),
                                if (estado == 'activo')
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _suspenderTorneo(id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text('Suspender', style: TextStyle(fontSize: 12)),
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => _cancelarTorneo(id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text('Cancelar', style: TextStyle(fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                if (estado == 'suspendido')
                                  ElevatedButton.icon(
                                    onPressed: () => _reanudarTorneo(id),
                                    icon: Icon(Icons.play_arrow, size: 14),
                                    label: Text('Reanudar', style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetalleTorneoScreen(torneo: torneo),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.info, size: 14),
                                  label: Text('Detalles', style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Constants.primaryColor,
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
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