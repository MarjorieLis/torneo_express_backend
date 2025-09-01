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
      print('❌ Error al cargar partidos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registrarResultado(String partidoId, String disciplina) async {
    final TextEditingController puntosLocalCtrl = TextEditingController();
    final TextEditingController puntosVisitanteCtrl = TextEditingController();

    final String labelLocal = disciplina == 'baloncesto' ? 'Aros Equipo Local' : 'Goles Equipo Local';
    final String labelVisitante = disciplina == 'baloncesto' ? 'Aros Equipo Visitante' : 'Goles Equipo Visitante';

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registrar Resultado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: puntosLocalCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: labelLocal),
              ),
              SizedBox(height: 10),
              TextField(
                controller: puntosVisitanteCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: labelVisitante),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final puntosLocal = int.tryParse(puntosLocalCtrl.text) ?? 0;
                  final puntosVisitante = int.tryParse(puntosVisitanteCtrl.text) ?? 0;

                  await ApiService.put('/partidos/$partidoId/registrar-resultado', {
                    'puntosLocal': puntosLocal,
                    'puntosVisitante': puntosVisitante
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Resultado registrado')),
                  );
                  Navigator.pop(context);
                  _cargarPartidos(); // Recargar lista
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: $e')),
                  );
                }
              },
              child: Text('Registrar'),
            )
          ],
        );
      },
    );
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
                    final disciplina = partido['disciplina'] ?? 'baloncesto';

                    // ✅ Extraer nombre del torneo desde partido.torneo.nombre
                    final nombreTorneo = partido['torneo'] is Map
                        ? partido['torneo']['nombre'] ?? 'Sin nombre'
                        : 'Sin nombre';

                    final equipoLocalNombre = partido['equipoLocal'] is Map
                        ? partido['equipoLocal']['nombre'] ?? 'Desconocido'
                        : 'Desconocido';

                    final equipoVisitanteNombre = partido['equipoVisitante'] is Map
                        ? partido['equipoVisitante']['nombre'] ?? 'Desconocido'
                        : 'Desconocido';

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
                            Text(
                              'Nombre del Torneo: $nombreTorneo',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Disciplina: $disciplina',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
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
                            Text('Estado: ${partido['estado'] ?? 'Programado'}'),
                            if (partido['estado'] == 'jugado')
                              Column(
                                children: [
                                  SizedBox(height: 5),
                                  Text(
                                    'Resultado: ${partido['resultado']['puntosLocal'] ?? 0} - ${partido['resultado']['puntosVisitante'] ?? 0}',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                            SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: partido['estado'] == 'programado'
                                  ? () => _registrarResultado(partido['_id'], disciplina)
                                  : null,
                              icon: Icon(Icons.score),
                              label: Text('Registrar Resultado'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constants.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 6),
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