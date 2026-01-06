// Archivo: fatiga_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/fatiga_model.dart'; // Importa el modelo

class FatigaProvider extends ChangeNotifier {
  bool showSurvey = true;
  List<PreguntaConfig> _preguntasActivas = [];
  List<bool?> _userAnswers = [];

  // Getters para que la vista lea los datos
  List<PreguntaConfig> get preguntasActivas => _preguntasActivas;
  List<bool?> get userAnswers => _userAnswers;

  // Constructor: Inicializa las preguntas al crear el provider
  FatigaProvider() {
    _inicializarPreguntas();
  }

  void _inicializarPreguntas() {
    List<PreguntaConfig> bancoDePreguntas = [
      PreguntaConfig(
        '¿Has dormido más de 7 horas en las últimas 24 horas?',
        true,
      ), // Ideal: SI
      PreguntaConfig(
        '¿Me encuentro físicamente apto para conducir?',
        true,
      ), // Ideal: SI
      PreguntaConfig(
        '¿Tienes dificultad para concentrarte?',
        false,
      ), // Ideal: NO
      PreguntaConfig(
        '¿He conducido más de 5 horas sin descansar?',
        false,
      ), // Ideal: NO
    ];

    bancoDePreguntas.shuffle(); // Barajar

    _preguntasActivas = bancoDePreguntas;
    _userAnswers = List.filled(_preguntasActivas.length, null);
    notifyListeners();
  }

  bool get allQuestionsAnswered => _userAnswers.every((a) => a != null);

  // Guardar una respuesta
  void setAnswer(int index, bool respuesta) {
    _userAnswers[index] = respuesta;
    notifyListeners();
  }

  // Lógica de evaluación
  // Retorna: TRUE si aprueba, FALSE si reprueba
  bool submitSurvey() {
    int puntajeCorrecto = 0;

    for (int i = 0; i < _preguntasActivas.length; i++) {
      if (_userAnswers[i] == _preguntasActivas[i].respuestaIdeal) {
        puntajeCorrecto++;
      }
    }

    // Regla: Se necesitan 2 o más respuestas correctas para aprobar
    bool aprobado = puntajeCorrecto >= 2;

    if (!aprobado) {
      showSurvey = false;
      notifyListeners();
    }

    return aprobado;
  }

  int get puntajeObtenido {
    int puntaje = 0;
    for (int i = 0; i < _preguntasActivas.length; i++) {
      if (_userAnswers[i] == _preguntasActivas[i].respuestaIdeal) {
        puntaje++;
      }
    }
    return puntaje;
  }
}
