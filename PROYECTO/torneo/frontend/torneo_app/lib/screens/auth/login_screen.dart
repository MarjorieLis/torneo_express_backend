// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:torneo_app/screens/jugador/perfil_jugador.dart';
import 'package:torneo_app/screens/organizador/perfil_organizador.dart';
import 'package:torneo_app/services/api_service.dart';
import 'package:torneo_app/utils/constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final data = {
        'email': _emailController.text.trim().toLowerCase(),
        'password': _passwordController.text,
      };

      try {
        final response = await ApiService.post('/auth/login', data);
        if (response.statusCode == 200) {
          final userData = response.data['user'];
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Inicio de sesión exitoso')),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['msg'] ?? 'Error de inicio')),
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
        title: const Text('Iniciar Sesión - Torneo UIDE'),
        backgroundColor: Constants.primaryColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Constants.backgroundColor,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Logo UIDE
              Image.asset(
                'assets/logo_uide.png',
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 20),
              Text(
                'Bienvenido de nuevo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Inicia sesión con tu correo institucional',
                style: TextStyle(color: Constants.textColor, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

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
              const SizedBox(height: 20),

              // Botón de login
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
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 15),

              // Enlace a registro
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}