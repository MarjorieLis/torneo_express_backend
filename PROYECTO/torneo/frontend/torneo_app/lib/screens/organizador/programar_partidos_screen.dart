// lib/screens/organizador/programar_partidos_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:intl/intl.dart';

class ProgramarPartidosScreen extends StatefulWidget {
  @override
  _ProgramarPartidosScreenState createState() => _ProgramarPartidosScreenState();
}

class _ProgramarPartidosScreenState extends State<ProgramarPartidosScreen> {
  List<Map<String, dynamic>> torneos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTorneos();
  }

  Future<void> _cargarTorneos() async {
    try {
      final response = await ApiService.get('/torneos');
      List data = [];

      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map && response.data.containsKey('torneos')) {
        data = response.data['torneos'];
      }

      setState(() {
        torneos = data.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('❌ Error al cargar torneos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _programarAutomatico(String torneoId) async {
    // ✅ Validación: asegurarse de que el ID no esté vacío
    if (torneoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ID del torneo no válido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('📤 Enviando a /partidos/automático con torneoId: $torneoId');

      final response = await ApiService.post('/partidos/automatico', {
        'torneoId': torneoId
      });

      print('✅ Respuesta del servidor: ${response.data}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${response.data['msg'] ?? 'Partidos programados'}')),
      );

      // ✅ Recargar torneos para reflejar cambios
      await _cargarTorneos();
    } on Exception catch (e) {
      print('❌ Error en la API: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ No se pudo programar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Programar Partidos'),
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
                    final inicio = DateTime.tryParse(torneo['fechaInicio'] ?? '');
                    final fin = DateTime.tryParse(torneo['fechaFin'] ?? '');

                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              torneo['nombre'] ?? 'Sin nombre',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text('Formato: ${torneo['formato'] ?? 'N/A'}'),
                            Text('Estado: ${torneo['estado'] ?? 'N/A'}'),
                            Text(
                              'Fechas: ${inicio != null ? DateFormat('dd/MM').format(inicio) : 'Inválida'} - ${fin != null ? DateFormat('dd/MM').format(fin) : 'Inválida'}',
                            ),
                            SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: torneo['estado'] == 'activo'
                                  ? () => _programarAutomatico(torneo['_id'])
                                  : null,
                              icon: Icon(Icons.autorenew),
                              label: Text('Programar Automáticamente'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constants.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 8),
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
}