import 'package:flutter/material.dart';
import 'package:torneo_app/utils/constants.dart';

class PerfilOrganizadorScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  PerfilOrganizadorScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil - Organizador'),
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
              child: Icon(Icons.business_center, size: 60, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              user['name'] ?? 'Organizador',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
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
            Card(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Tienes acceso a crear torneos, gestionar equipos y programar partidos.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}