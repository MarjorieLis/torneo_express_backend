// lib/screens/jugador/inscribir_equipo_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'seleccionar_jugadores_screen.dart'; // ✅ Importa el nuevo widget

class InscribirEquipoScreen extends StatefulWidget {
  final Map<String, dynamic> torneo;

  const InscribirEquipoScreen({super.key, required this.torneo});

  @override
  _InscribirEquipoScreenState createState() => _InscribirEquipoScreenState();
}

class _InscribirEquipoScreenState extends State<InscribirEquipoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  String? _disciplina;
  List<String> _jugadoresSeleccionados = [];

  @override
  void initState() {
    super.initState();
    _disciplina = widget.torneo['disciplina'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscribir Equipo'),
        backgroundColor: Constants.primaryColor,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Información del Equipo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Nombre del equipo
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del equipo *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 15),

              // Disciplina (bloqueado)
              TextFormField(
                initialValue: _disciplina,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Disciplina deportiva *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 15),

              // Cédula del capitán
              TextFormField(
                controller: _cedulaController,
                decoration: InputDecoration(
                  labelText: 'Cédula del capitán *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 20),

              // Botón para seleccionar jugadores
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeleccionarJugadoresScreen(
                        disciplina: _disciplina!,
                        cedulaCapitan: _cedulaController.text,
                      ),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      _jugadoresSeleccionados = result;
                    });
                  }
                },
                icon: Icon(Icons.people),
                label: Text('Seleccionar Jugadores'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              // Mostrar jugadores seleccionados
              if (_jugadoresSeleccionados.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    Text(
                      'Jugadores seleccionados (${_jugadoresSeleccionados.length})',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _jugadoresSeleccionados.map((id) {
                        return Chip(
                          label: Text('Jugador $id'),
                          deleteIcon: Icon(Icons.close),
                          onDeleted: () {
                            setState(() {
                              _jugadoresSeleccionados.remove(id);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),

              SizedBox(height: 20),

              // Botón final
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      'nombre': _nombreController.text,
                      'disciplina': _disciplina,
                      'cedulaCapitan': _cedulaController.text,
                      'jugadores': _jugadoresSeleccionados,
                      'torneoId': widget.torneo['_id']
                    };

                    try {
                      final response = await ApiService.post('/equipos', data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ Equipo inscrito, pendiente de aprobación')),
                      );
                      Navigator.pop(context);
                    } on Exception catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Inscribir Equipo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}