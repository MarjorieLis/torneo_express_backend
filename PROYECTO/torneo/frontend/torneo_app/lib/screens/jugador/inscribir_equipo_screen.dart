// lib/screens/jugador/inscribir_equipo_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:torneo_app/utils/helpers.dart';

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
  Set<String> _cedulasUsadas = {};
  String? _disciplina;
  int _minJugadores = 5;
  int _maxJugadores = 12;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _disciplina = widget.torneo['disciplina'];
    _minJugadores = widget.torneo['minJugadores'] ?? 5;
    _maxJugadores = widget.torneo['maxJugadores'] ?? 12;
    _cargarJugadoresExistentes();
  }

  Future<void> _cargarJugadoresExistentes() async {
    try {
      final response = await ApiService.get('/equipos/torneo/${widget.torneo['_id']}/inscritos');
      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          _cedulasUsadas = response.data.map((c) => c.toString()).toSet();
        });
      }
    } on Exception catch (e) {
      print('⚠️ Error al cargar jugadores existentes: $e');
    }
  }

  void _agregarJugador() {
    final nombre = _nombreJugadorController.text.trim();
    final cedula = _cedulaJugadorController.text.trim();

    if (nombre.isEmpty || cedula.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nombre y cédula son obligatorios')),
      );
      return;
    }

    if (_jugadores.length >= _maxJugadores) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pueden agregar más de $_maxJugadores jugadores para $_disciplina')),
      );
      return;
    }

    if (_cedulasUsadas.contains(cedula)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El jugador con cédula $cedula ya está inscrito en otro equipo')),
      );
      return;
    }

    setState(() {
      _jugadores.add({'nombre': nombre, 'cedula': cedula});
      _cedulasUsadas.add(cedula);
      _nombreJugadorController.clear();
      _cedulaJugadorController.clear();
    });
  }

  void _eliminarJugador(int index) {
    setState(() {
      final cedula = _jugadores[index]['cedula'];
      _cedulasUsadas.remove(cedula);
      _jugadores.removeAt(index);
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final totalJugadores = _jugadores.length + 1;
    final capitanCedula = _cedulaCapitanController.text.trim();

    if (totalJugadores < _minJugadores) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se requieren al menos $_minJugadores jugadores para $_disciplina')),
      );
      return;
    }

    if (totalJugadores > _maxJugadores) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Máximo permitido: $_maxJugadores jugadores para $_disciplina')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'nombre': _nombreController.text.trim(),
      'disciplina': _disciplina,
      'torneoId': widget.torneo['_id'],
      'capitán': {
        'nombre': _capitanController.text.trim(),
        'cedula': capitanCedula
      },
      'cedulaCapitan': capitanCedula,
      'jugadores': _jugadores,
      'estado': 'pendiente'
    };

    try {
      final response = await ApiService.post('/equipos', data);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Equipo inscrito con éxito')),
        );

        // ✅ Recargar todos los torneos
        final torneosActualizados = await ApiService.get('/torneos');
        if (torneosActualizados.statusCode == 200) {
          Navigator.pop(context, torneosActualizados.data);
        } else {
          Navigator.pop(context);
        }
      } else {
        final errorMsg = response.data['msg'] ?? 'Error al inscribir equipo';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $errorMsg')),
        );
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error de conexión: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalJugadores = _jugadores.length + 1;

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

              // Categoría del torneo
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    '${capitalize(widget.torneo['categoria'])} • $_disciplina: $_minJugadores - $_maxJugadores jugadores',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Contador de jugadores
              Text(
                'Jugadores: $totalJugadores / $_maxJugadores',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: totalJugadores >= _maxJugadores ? Colors.red : Colors.green,
                ),
              ),
              SizedBox(height: 15),

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
                onPressed: _jugadores.length >= _maxJugadores ? null : _agregarJugador,
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