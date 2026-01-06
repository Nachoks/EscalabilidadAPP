// Archivo: somnolencia_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/somnolencia_model.dart';

class SomnolenciaProvider extends ChangeNotifier {
  bool showSurvey = true;
  List<PreguntaConfig> _preguntasActivas = [];
  List<bool?> _userAnswers = [];

  List<PreguntaConfig> get preguntasActivas => _preguntasActivas;
  List<bool?> get userAnswers => _userAnswers;

  // Constructor
  SomnolenciaProvider() {
    _inicializarPreguntas();
  }

  void _inicializarPreguntas() {
    List<PreguntaConfig> bancoDePreguntas = [
      PreguntaConfig('¿Sientes sueño en este momento?', false), // Ideal: NO
      PreguntaConfig(
        '¿Te sientes suficientemente alerta para conducir?',
        true,
      ), // Ideal: SI
      PreguntaConfig('¿Sientes pesadez en los ojos?', false), // Ideal: NO
      PreguntaConfig(
        '¿Tus movimientos son más lentos o torpes de lo normal?',
        false,
      ), // Ideal: NO
    ];

    bancoDePreguntas.shuffle();

    _preguntasActivas = bancoDePreguntas;
    _userAnswers = List.filled(_preguntasActivas.length, null);
    notifyListeners();
  }

  bool get allQuestionsAnswered => _userAnswers.every((a) => a != null);

  void setAnswer(int index, bool value) {
    _userAnswers[index] = value;
    notifyListeners();
  }

  int get puntajeCorrecto {
    int puntaje = 0;
    for (int i = 0; i < _preguntasActivas.length; i++) {
      if (_userAnswers[i] == _preguntasActivas[i].respuestaIdeal) {
        puntaje++;
      }
    }
    return puntaje;
  }

  // Retorna TRUE si aprueba, FALSE si reprueba
  bool submitSurvey() {
    // REGLA: Si tiene 2 o más respuestas seguras, aprueba.
    bool aprobado = puntajeCorrecto >= 2;

    if (!aprobado) {
      showSurvey = false; // Cambia a pantalla roja
      notifyListeners();
    }

    return aprobado;
  }
}
