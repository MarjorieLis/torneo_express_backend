// lib/screens/organizador/crear_torneo_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';
import 'package:intl/intl.dart';

class CrearTorneoScreen extends StatefulWidget {
  @override
  _CrearTorneoScreenState createState() => _CrearTorneoScreenState();
}

class _CrearTorneoScreenState extends State<CrearTorneoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _reglasController = TextEditingController();
  String? _disciplina;
  String? _formato;
  String? _categoria;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int? _maxEquipos;
  int? _minJugadores;
  int? _maxJugadores;

  Future<void> _selectFecha(BuildContext context, bool esInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es'),
    );
    if (picked != null) {
      setState(() {
        if (esInicio) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaInicio == null || _fechaFin == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selecciona ambas fechas')),
        );
        return;
      }

      if (_fechaInicio!.isAfter(_fechaFin!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La fecha de inicio debe ser anterior a la de fin')),
        );
        return;
      }

      if (_minJugadores == null || _maxJugadores == null || _minJugadores! > _maxJugadores!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verifica los límites de jugadores')),
        );
        return;
      }

      // ✅ Aseguramos que todos los campos estén presentes
      final data = {
        'nombre': _nombreController.text.trim(),
        'disciplina': _disciplina,
        'categoria': _categoria,
        'fechaInicio': _fechaInicio?.toIso8601String(),
        'fechaFin': _fechaFin?.toIso8601String(),
        'maxEquipos': _maxEquipos,
        'minJugadores': _minJugadores,
        'maxJugadores': _maxJugadores,
        'reglas': _reglasController.text.trim(),
        'formato': _formato,
      };

      try {
        print('Enviando datos al backend: $data'); // 🔍 Depuración

        final response = await ApiService.post('/torneos', data);

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Torneo creado con éxito')),
          );
          Navigator.pop(context);
        } else {
          final errorMsg = response.data['msg'] ?? 'Error desconocido';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: $errorMsg')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error de conexión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Torneo'),
        backgroundColor: Constants.primaryColor,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        color: Constants.backgroundColor,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Información del Torneo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor,
                ),
              ),
              SizedBox(height: 20),

              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del torneo *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 15),

              // Disciplina
              DropdownButtonFormField(
                value: _disciplina,
                items: ['fútbol', 'baloncesto', 'voleibol', 'tenis']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                hint: Text('Disciplina deportiva *'),
                onChanged: (v) => setState(() => _disciplina = v),
                validator: (v) => v == null ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 15),

              // Categoría
              DropdownButtonFormField(
                value: _categoria,
                items: ['masculino', 'femenino', 'mixto']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.capitalize())))
                    .toList(),
                hint: Text('Categoría del torneo *'),
                onChanged: (v) => setState(() => _categoria = v),
                validator: (v) => v == null ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 15),

              // Fechas
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _selectFecha(context, true),
                      icon: Icon(Icons.calendar_today),
                      label: Text(
                        _fechaInicio == null
                            ? 'Inicio'
                            : DateFormat('dd/MM/yyyy').format(_fechaInicio!),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _selectFecha(context, false),
                      icon: Icon(Icons.calendar_today),
                      label: Text(
                        _fechaFin == null
                            ? 'Fin'
                            : DateFormat('dd/MM/yyyy').format(_fechaFin!),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Máximo equipos
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Máximo equipos *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _maxEquipos = int.tryParse(v),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 15),

              // Mínimo jugadores por equipo
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mínimo jugadores por equipo *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _minJugadores = int.tryParse(v),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 15),

              // Máximo jugadores por equipo
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Máximo jugadores por equipo *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _maxJugadores = int.tryParse(v),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 15),

              // Formato
              DropdownButtonFormField(
                value: _formato,
                items: ['grupos', 'eliminación directa', 'mixto']
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                hint: Text('Formato del torneo *'),
                onChanged: (v) => setState(() => _formato = v),
                validator: (v) => v == null ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 15),

              // Reglas
              TextFormField(
                controller: _reglasController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Reglas del torneo *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 20),

              // Botón
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Crear Torneo',
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

// Extensión para capitalizar palabras
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}