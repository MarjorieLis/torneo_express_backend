// lib/screens/organizador/perfil_organizador.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:torneo_app/services/auth_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'crear_torneo_screen.dart';
import 'lista_torneos_screen.dart'; // Asegúrate de tener este archivo

class PerfilOrganizadorScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const PerfilOrganizadorScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil - Organizador'),
        backgroundColor: Constants.primaryColor,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user['name'] ?? 'Organizador'),
              accountEmail: Text(user['email'] ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.business_center, color: Constants.primaryColor),
              ),
              decoration: BoxDecoration(
                color: Constants.primaryColor,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Mi Perfil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Mis Torneos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/lista_torneos');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Cerrar sesión'),
              onTap: () async {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
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
              child: Icon(Icons.business_center, size: 40, color: Colors.white),
            ),
            SizedBox(height: 15),
            Text(
              user['name'] ?? 'Organizador',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              user['email'] ?? '',
              style: TextStyle(color: Constants.textColor),
            ),
            SizedBox(height: 10),
            Text(
              'Rol: Organizador',
              style: TextStyle(color: Constants.primaryColor, fontSize: 18),
            ),
            SizedBox(height: 20),

            // Mensaje de acceso
            Card(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Tienes acceso a crear torneos, gestionar equipos y programar partidos.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: 30),

            // Botón para crear torneo
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/crear_torneo');
              },
              icon: Icon(Icons.add_circle),
              label: Text('Crear Torneo'),
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
