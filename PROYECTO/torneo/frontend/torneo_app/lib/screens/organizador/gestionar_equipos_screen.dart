// lib/screens/organizador/gestionar_equipos_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:torneo_app/utils/helpers.dart';

class GestionarEquiposScreen extends StatefulWidget {
  @override
  _GestionarEquiposScreenState createState() => _GestionarEquiposScreenState();
}

class _GestionarEquiposScreenState extends State<GestionarEquiposScreen> {
  List<Map<String, dynamic>> equipos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  Future<void> _cargarEquipos() async {
    try {
      final response = await ApiService.get('/equipos');
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map && response.data.containsKey('equipos')) {
          setState(() {
            equipos = List<Map<String, dynamic>>.from(response.data['equipos']);
            _isLoading = false;
          });
        } else if (response.data is List) {
          setState(() {
            equipos = response.data.cast<Map<String, dynamic>>();
            _isLoading = false;
          });
        } else {
          setState(() {
            equipos = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar equipos')),
        );
      }
    } on Exception catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  void _aprobarEquipo(String id) async {
    try {
      final response = await ApiService.put('/equipos/$id/aprobar', {});
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Equipo aprobado')),
        );
        _cargarEquipos();
      } else {
        final errorMsg = response.data['msg'] ?? 'Error al aprobar equipo';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $errorMsg')), // ✅ Corregido: $errorMsg
        );
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  void _rechazarEquipo(String id) async {
    try {
      final response = await ApiService.put('/equipos/$id/rechazar', {});
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Equipo rechazado')),
        );
        _cargarEquipos();
      } else {
        final errorMsg = response.data['msg'] ?? 'Error al rechazar equipo';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $errorMsg')), // ✅ Corregido: $errorMsg
        );
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Equipos'),
        backgroundColor: Constants.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : equipos.isEmpty
              ? Center(child: Text('No hay equipos pendientes'))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: equipos.length,
                  itemBuilder: (context, index) {
                    final equipo = equipos[index];
                    final capitan = equipo['capitán']; // ✅ Sin tilde
                    final cedulaCapitan = equipo['cedulaCapitan'];
                    final nombreCapitan = capitan?['nombre'] ?? 'Sin nombre'; // ✅ Sin tilde

                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              equipo['nombre'] ?? 'Sin nombre',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('Disciplina: ${capitalize(equipo['disciplina'])}'),
                            Text('Cédula del capitán: $cedulaCapitan'),
                            Text('Nombre del capitán: $nombreCapitan'), // ✅ Mostrado
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getColorPorEstado(equipo['estado']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                equipo['estado'].toUpperCase(),
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _aprobarEquipo(equipo['_id']),
                                  icon: Icon(Icons.check_circle),
                                  label: Text('Aprobar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () => _rechazarEquipo(equipo['_id']),
                                  icon: Icon(Icons.close),
                                  label: Text('Rechazar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Color _getColorPorEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'aprobado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}