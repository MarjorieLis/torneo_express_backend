// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Pantallas
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/organizador/perfil_organizador.dart';
import 'screens/organizador/crear_torneo_screen.dart';
import 'screens/jugador/seleccionar_torneo_screen.dart';
import 'screens/jugador/inscribir_equipo_screen.dart';
import 'screens/organizador/lista_torneos_screen.dart' as lista_torneos;
import 'package:torneo_app/screens/organizador/gestionar_equipos_screen.dart';

// ✅ Importa explícitamente las pantallas del jugador
import 'package:torneo_app/screens/jugador/perfil_jugador.dart';
import 'package:torneo_app/screens/jugador/mis_torneos_screen.dart';

// Servicios
import 'services/api_service.dart';
import 'services/auth_service.dart';

// Utilidades
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  ApiService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Torneo UIDE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Constants.primaryColor,
        scaffoldBackgroundColor: Constants.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: Constants.primaryColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Constants.primaryColor,
          primary: Constants.primaryColor,
          onPrimary: Colors.white,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Constants.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Constants.primaryColor, width: 2),
          ),
          labelStyle: TextStyle(color: Constants.primaryColor),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/perfil_jugador': (context) {
          final user = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return PerfilJugadorScreen(user: user ?? {});
        },
        '/perfil_organizador': (context) {
          final user = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return PerfilOrganizadorScreen(user: user ?? {});
        },
        '/crear_torneo': (context) => CrearTorneoScreen(),
        '/seleccionar_torneo': (context) => SeleccionarTorneoScreen(),
        '/inscribir_equipo': (context) {
          final torneo = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return InscribirEquipoScreen(torneo: torneo ?? {});
        },
        '/lista_torneos': (context) => lista_torneos.ListaTorneosScreen(),
        '/gestionar_equipos': (context) => GestionarEquiposScreen(),
        '/mis_torneos': (context) {
          final user = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return MisTorneosScreen(user: user ?? {});
        },
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es', ''),
      ],
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Constants.primaryColor, const Color(0xFF0057B7)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_uide.png',
              height: 120,
              width: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Torneo UIDE',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Organización de Torneos Deportivos',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Constants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'Crear Cuenta',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}