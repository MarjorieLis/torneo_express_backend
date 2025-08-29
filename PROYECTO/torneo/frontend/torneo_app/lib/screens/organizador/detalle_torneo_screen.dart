// lib/screens/organizador/detalle_torneo_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:intl/intl.dart';

class DetalleTorneoScreen extends StatelessWidget {
  final Map<String, dynamic> torneo;

  const DetalleTorneoScreen({super.key, required this.torneo});

  @override
  Widget build(BuildContext context) {
    final DateFormat formato = DateFormat('dd/MM/yyyy');
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
                // Nombre
                Text(
                  torneo['nombre'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                // Disciplina
                Row(
                  children: [
                    Icon(Icons.sports, color: Constants.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      torneo['disciplina'].toUpperCase(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Fechas
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Constants.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      '${formato.format(DateTime.parse(torneo['fechaInicio']))} - ${formato.format(DateTime.parse(torneo['fechaFin']))}',
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // Máximo equipos
                Row(
                  children: [
                    Icon(Icons.group, color: Constants.primaryColor),
                    SizedBox(width: 8),
                    Text('Equipos máximos: ${torneo['maxEquipos']}'),
                  ],
                ),
                SizedBox(height: 15),
                // Formato
                Row(
                  children: [
                    Icon(Icons.format_list_bulleted, color: Constants.primaryColor),
                    SizedBox(width: 8),
                    Text('Formato: ${torneo['formato'].toUpperCase()}'),
                  ],
                ),
                SizedBox(height: 15),
                // Estado
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
                        torneo['estado'].toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Reglas
                Text(
                  'Reglas del torneo:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  torneo['reglas'],
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
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