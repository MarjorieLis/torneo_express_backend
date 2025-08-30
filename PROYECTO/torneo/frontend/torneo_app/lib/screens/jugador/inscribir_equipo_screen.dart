// lib/screens/jugador/inscribir_equipo_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';

class InscribirEquipoScreen extends StatefulWidget {
  final Map<String, dynamic> torneo;

  const InscribirEquipoScreen({super.key, required this.torneo});

  @override
  _InscribirEquipoScreenState createState() => _InscribirEquipoScreenState();
}

class _InscribirEquipoScreenState extends State<InscribirEquipoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _capitanController = TextEditingController();
  final _cedulaCapitanController = TextEditingController();
  final _nombreJugadorController = TextEditingController();
  final _cedulaJugadorController = TextEditingController();

  List<Map<String, String>> _jugadores = [];
  String? _disciplina;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _disciplina = widget.torneo['disciplina'];
  }

  void _agregarJugador() {
    if (_nombreJugadorController.text.isNotEmpty && _cedulaJugadorController.text.isNotEmpty) {
      setState(() {
        _jugadores.add({
          'nombre': _nombreJugadorController.text,
          'cedula': _cedulaJugadorController.text
        });
        _nombreJugadorController.clear();
        _cedulaJugadorController.clear();
      });
    }
  }

  void _eliminarJugador(int index) {
    setState(() {
      _jugadores.removeAt(index);
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final data = {
        'nombre': _nombreController.text.trim(),
        'disciplina': _disciplina,
        'torneoId': widget.torneo['_id'],
        'capitan': {
          'nombre': _capitanController.text,
          'cedula': _cedulaCapitanController.text,
        },
        'jugadores': _jugadores.map((j) => '${j['nombre']} (${j['cedula']})').toList(),
        'estado': 'pendiente'
      };

      try {
        final response = await ApiService.post('/equipos', data);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Equipo inscrito con éxito')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.data['msg'] ?? 'Desconocido'}')),
          );
        }
      } on Exception catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscribir Equipo - ${widget.torneo['nombre']}'),
        backgroundColor: Constants.primaryColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Constants.backgroundColor,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Información del Equipo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor,
                ),
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

              // Capitán
              TextFormField(
                controller: _capitanController,
                decoration: InputDecoration(
                  labelText: 'Nombre del capitán *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 15),

              // Cédula del capitán
              TextFormField(
                controller: _cedulaCapitanController,
                decoration: InputDecoration(
                  labelText: 'Cédula del capitán *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 20),

              // Sección: Agregar otros jugadores
              Text(
                'Agregar Jugadores',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor,
                ),
              ),
              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nombreJugadorController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del jugador',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _cedulaJugadorController,
                      decoration: InputDecoration(
                        labelText: 'Cédula',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _agregarJugador,
                icon: Icon(Icons.add),
                label: Text('Agregar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 15),

              // Lista de jugadores agregados
              if (_jugadores.isNotEmpty) ...[
                Text(
                  'Jugadores agregados (${_jugadores.length})',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _jugadores.length,
                  itemBuilder: (context, index) {
                    final jugador = _jugadores[index];
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('${jugador['nombre']} - ${jugador['cedula']}'),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarJugador(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
              ],

              // Botón de inscripción
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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