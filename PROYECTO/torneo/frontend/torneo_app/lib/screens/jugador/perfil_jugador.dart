// lib/screens/jugador/perfil_jugador.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:torneo_app/services/auth_service.dart';
import 'package:torneo_app/utils/constants.dart';

class PerfilJugadorScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const PerfilJugadorScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil - Jugador'),
        backgroundColor: Constants.primaryColor,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        color: Constants.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: Constants.primaryColor,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            SizedBox(height: 15),
            Text(
              user['name'] ?? 'Jugador',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              user['email'] ?? '',
              style: TextStyle(color: Constants.textColor),
            ),
            SizedBox(height: 10),
            Text(
              'Rol: Jugador',
              style: TextStyle(color: Constants.primaryColor, fontSize: 18),
            ),
            SizedBox(height: 20),

            // Información personal
            Card(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información personal',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.credit_card, size: 18, color: Constants.primaryColor),
                        SizedBox(width: 8),
                        Text('Identificación: ${user['cedula'] ?? 'No registrada'}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.sports, size: 18, color: Constants.primaryColor),
                        SizedBox(width: 8),
                        Text('Posición: ${user['position'] ?? 'No especificada'}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.tag_faces, size: 18, color: Constants.primaryColor),
                        SizedBox(width: 8),
                        Text('Camiseta: #${user['jerseyNumber'] ?? '0'}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sesión cerrada')),
                );
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: Icon(Icons.exit_to_app),
              label: Text('Cerrar sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}