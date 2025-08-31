// lib/screens/jugador/mis_torneos_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:torneo_app/utils/helpers.dart';

class MisTorneosScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const MisTorneosScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Torneos'),
        backgroundColor: Constants.primaryColor,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cargarTorneosInscritos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar torneos: ${snapshot.error}'));
          }
          if (snapshot.data?.isEmpty ?? true) {
            return Center(child: Text('No estás inscrito en ningún torneo'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final torneo = snapshot.data![index];
              final equipo = torneo['equipo'] ?? {};
              final estadoEquipo = equipo['estado'] ?? 'pendiente';

              return Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        torneo['nombre'] ?? 'Sin nombre',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text('${capitalize(torneo['disciplina'])} • ${torneo['categoria']}'),
                      SizedBox(height: 5),
                      Text('Equipo: ${equipo['nombre'] ?? 'Sin equipo'}'),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getColorPorEstado(estadoEquipo),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          estadoEquipo.toUpperCase(),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _cargarTorneosInscritos() async {
    try {
      final cedula = user['cedula']?.toString() ?? '';
      if (cedula.isEmpty) {
        print('❌ Cédula no disponible en el usuario');
        return [];
      }

      final response = await ApiService.get('/equipos/jugador/$cedula/torneos');
      if (response.statusCode == 200 && response.data is Map && response.data.containsKey('torneos')) {
        return response.data['torneos'].cast<Map<String, dynamic>>();
      }
      return [];
    } on Exception catch (e) {
      print('❌ Error al cargar torneos inscritos: $e');
      return [];
    }
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