// lib/screens/organizador/detalle_torneo_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:torneo_app/utils/extensions.dart';

class DetalleTorneoScreen extends StatelessWidget {
  final Map<String, dynamic> torneo;

  const DetalleTorneoScreen({super.key, required this.torneo});

  @override
  Widget build(BuildContext context) {
    final DateFormat formato = DateFormat('dd/MM/yyyy');
    final int maxEquipos = torneo['maxEquipos'] ?? 0;
    final int equiposRegistrados = torneo['equiposRegistrados'] ?? 0;
    final int equiposRestantes = maxEquipos - equiposRegistrados;
    final int minJugadores = torneo['minJugadores'] ?? 1;
    final int maxJugadores = torneo['maxJugadores'] ?? 15;
    final String? categoria = torneo['categoria'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Torneo'),
        backgroundColor: Constants.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  torneo['nombre'] ?? 'Sin nombre',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.sports, color: Constants.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      (torneo['disciplina'] ?? 'Sin disciplina').toUpperCase(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // ✅ Mostrar categoría
                if (categoria != null)
                  Row(
                    children: [
                      Icon(Icons.group, color: Constants.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Categoría: ${categoria.capitalize()}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Categoría: No definida',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Constants.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      _formatFechas(torneo['fechaInicio'], torneo['fechaFin'], formato),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                Row(
                  children: [
                    Icon(Icons.group, color: Constants.primaryColor),
                    SizedBox(width: 8),
                    Text('Equipos máximos: $maxEquipos'),
                  ],
                ),
                SizedBox(height: 10),

                Text(
                  'Equipos registrados: $equiposRegistrados',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                LinearProgressIndicator(
                  value: maxEquipos > 0 ? equiposRegistrados / maxEquipos : 0,
                  backgroundColor: Colors.grey[200],
                  color: Constants.primaryColor,
                ),
                Text('Equipos restantes: $equiposRestantes'),
                SizedBox(height: 15),

                Row(
                  children: [
                    Icon(Icons.format_list_bulleted, color: Constants.primaryColor),
                    SizedBox(width: 8),
                    Text('Formato: ${_capitalize(torneo['formato'] ?? 'N/A')}'),
                  ],
                ),
                SizedBox(height: 15),

                Row(
                  children: [
                    Icon(Icons.flag, color: Constants.primaryColor),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getColorPorEstado(torneo['estado']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (torneo['estado'] ?? 'desconocido').toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                Row(
                  children: [
                    Icon(Icons.person, color: Constants.primaryColor),
                    SizedBox(width: 8),
                    Text('Jugadores por equipo: $minJugadores - $maxJugadores'),
                  ],
                ),
                SizedBox(height: 15),

                Text(
                  'Reglas del torneo:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  torneo['reglas'] ?? 'No hay reglas definidas.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatFechas(dynamic inicio, dynamic fin, DateFormat formato) {
    try {
      final DateTime? fechaInicio = inicio is String ? DateTime.tryParse(inicio) : null;
      final DateTime? fechaFin = fin is String ? DateTime.tryParse(fin) : null;

      if (fechaInicio != null && fechaFin != null) {
        return '${formato.format(fechaInicio)} - ${formato.format(fechaFin)}';
      }
      return 'Fechas no disponibles';
    } catch (e) {
      return 'Fechas no válidas';
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
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