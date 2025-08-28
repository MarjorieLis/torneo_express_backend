import 'package:flutter/material.dart';
import 'package:torneo_app/utils/constants.dart';

class PerfilJugadorScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  PerfilJugadorScreen({required this.user});

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
            CircleAvatar(
              radius: 60,
              backgroundColor: Constants.secondaryColor,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              user['name'] ?? 'Jugador',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
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
            ListTile(
              title: Text('Posición: ${user['position'] ?? 'No especificada'}'),
              leading: Icon(Icons.sports),
            ),
            ListTile(
              title: Text('Camiseta: #${user['jerseyNumber'] ?? '0'}'),
              leading: Icon(Icons.tag_faces),
            ),
          ],
        ),
      ),
    );
  }
}