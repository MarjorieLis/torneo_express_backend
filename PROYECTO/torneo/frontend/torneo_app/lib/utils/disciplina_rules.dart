// lib/utils/disciplina_rules.dart
class DisciplinaRules {
  static Map<String, Map<String, int>> reglas = {
    'fútbol': {'min': 11, 'max': 18},
    'baloncesto': {'min': 5, 'max': 12},
    'voleibol': {'min': 6, 'max': 12},
    'tenis': {'min': 1, 'max': 2}, // Dobles
    'atletismo': {'min': 1, 'max': 5}, // Relevos
  };

  static int minJugadores(String disciplina) {
    return reglas[disciplina.toLowerCase()]?['min'] ?? 1;
  }

  static int maxJugadores(String disciplina) {
    return reglas[disciplina.toLowerCase()]?['max'] ?? 15;
  }

  static bool esValida(String disciplina) {
    return reglas.containsKey(disciplina.toLowerCase());
  }
}