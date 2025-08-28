// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/screens/jugador/perfil_jugador.dart';
import 'package:torneo_app/screens/organizador/perfil_organizador.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _positionController = TextEditingController();
  final _jerseyNumberController = TextEditingController();
  final _cedulaController = TextEditingController();

  String? _role;
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final data = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'password': _passwordController.text,
        'role': _role ?? 'jugador',
        'position': _role == 'jugador' ? _positionController.text.trim() : null,
        'jerseyNumber': _role == 'jugador' ? (int.tryParse(_jerseyNumberController.text) ?? null) : null,
        'cedula': _role == 'jugador' ? _cedulaController.text.trim() : null,
      };

      try {
        final response = await ApiService.post('/auth/register', data);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final userData = response.data['user'];
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Registro exitoso')),
          );

          if (userData['role'] == 'organizador') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PerfilOrganizadorScreen(user: userData),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PerfilJugadorScreen(user: userData),
              ),
            );
          }
        } else {
          final errorMsg = response.data['msg'] ?? 'Error en el registro';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ $errorMsg')),
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
        title: const Text('Registro - Torneo UIDE'),
        backgroundColor: Constants.primaryColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Constants.backgroundColor,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Image.asset(
                'assets/logo_uide.png',
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 20),
              Text(
                'Crear tu cuenta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Solo para estudiantes @uide.edu.ec',
                style: TextStyle(color: Constants.textColor, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre completo *',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Constants.primaryColor, width: 2),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 15),

              // Correo
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo @uide.edu.ec *',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Constants.primaryColor, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'Campo obligatorio';
                  if (!v.endsWith('@uide.edu.ec')) return 'Solo correos @uide.edu.ec';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña *',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Constants.primaryColor, width: 2),
                  ),
                ),
                validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 15),

              // Rol
              DropdownButtonFormField(
                value: _role,
                decoration: InputDecoration(
                  labelText: '¿Eres jugador u organizador?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'jugador', child: Text('Soy Jugador')),
                  DropdownMenuItem(value: 'organizador', child: Text('Soy Organizador')),
                ],
                onChanged: (v) => setState(() => _role = v),
                validator: (v) => v == null ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 15),

              // Campos condicionales para jugador
              if (_role == 'jugador') ...[
                TextFormField(
                  controller: _cedulaController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Número de identificación *',
                    hintText: 'Cédula o pasaporte',
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return 'Este campo es obligatorio';
                    if (v.length < 5) return 'Debe tener al menos 5 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _positionController,
                  decoration: InputDecoration(
                    labelText: 'Posición principal',
                    prefixIcon: const Icon(Icons.sports),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _jerseyNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Número de camiseta',
                    prefixIcon: const Icon(Icons.tag_faces),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),
              ],

              // Botón de registro
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Crear Cuenta',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}