// lib/screens/jugador/perfil_jugador.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/services/auth_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:intl/intl.dart';

class PerfilJugadorScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const PerfilJugadorScreen({super.key, required this.user});

  @override
  State<PerfilJugadorScreen> createState() => _PerfilJugadorScreenState();
}

class _PerfilJugadorScreenState extends State<PerfilJugadorScreen> {
  bool _loadingAuth = true;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.token == null) {
      // Si no hay token, redirigir al login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    setState(() {
      _loadingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingAuth) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil - Jugador'),
        backgroundColor: Constants.primaryColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        color: Constants.backgroundColor,
        child: SingleChildScrollView(
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
                widget.user['name'] ?? 'Jugador',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                widget.user['email'] ?? '',
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
                          Text('Identificación: ${widget.user['cedula'] ?? 'No registrada'}'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.sports, size: 18, color: Constants.primaryColor),
                          SizedBox(width: 8),
                          Text('Posición: ${widget.user['position'] ?? 'No especificada'}'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.tag_faces, size: 18, color: Constants.primaryColor),
                          SizedBox(width: 8),
                          Text('Camiseta: #${widget.user['jerseyNumber'] ?? '0'}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Torneos disponibles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Constants.primaryColor),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/seleccionar_torneo');
                    },
                    icon: Icon(Icons.add, size: 16),
                    label: Text('Inscribir', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Lista de torneos disponibles
              FutureBuilder(
                future: _cargarTorneos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error al cargar torneos: ${snapshot.error}');
                  }
                  final List torneos = snapshot.data ?? [];
                  if (torneos.isEmpty) {
                    return Text('No hay torneos disponibles');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: torneos.length,
                    itemBuilder: (context, index) {
                      final torneo = torneos[index];
                      final estado = torneo['estado'] ?? 'activo';
                      final int maxEquipos = torneo['maxEquipos'] ?? 0;
                      final int equiposRegistrados = torneo['equiposRegistrados'] ?? 0;
                      final int equiposRestantes = maxEquipos - equiposRegistrados;

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
                              Text('Disciplina: ${torneo['disciplina'] ?? 'N/A'}'),
                              Text('Equipos: $equiposRegistrados/$maxEquipos'),
                              LinearProgressIndicator(
                                value: maxEquipos > 0 ? equiposRegistrados / maxEquipos : 0,
                                backgroundColor: Colors.grey[200],
                                color: Constants.primaryColor,
                              ),
                              Text('Restantes: $equiposRestantes', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              SizedBox(height: 5),
                              Text(
                                'Fechas: ${DateFormat('dd/MM').format(DateTime.parse(torneo['fechaInicio']))} - ${DateFormat('dd/MM').format(DateTime.parse(torneo['fechaFin']))}',
                              ),
                              SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getColorPorEstado(estado),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  estado.toUpperCase(),
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
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.user['name'] ?? 'Jugador'),
              accountEmail: Text(widget.user['email'] ?? ''),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person),
              ),
              decoration: BoxDecoration(color: Constants.primaryColor),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Mi Perfil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.sports),
              title: Text('Mis Torneos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/mis_torneos', arguments: widget.user);
              },
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Calendario'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Cerrar sesión'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List> _cargarTorneos() async {
    try {
      final response = await ApiService.get('/torneos');
      final data = response.data;

      if (data is List) {
        return data;
      } else if (data is Map) {
        if (data.containsKey('data') && data['data'] is List) {
          return data['data'];
        } else if (data.containsKey('torneos') && data['torneos'] is List) {
          return data['torneos'];
        }
      }
      return [];
    } on Exception catch (e) {
      throw Exception('Error al cargar torneos: $e');
    }
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
