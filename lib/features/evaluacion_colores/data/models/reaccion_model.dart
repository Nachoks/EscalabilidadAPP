// Archivo: reaccion_model.dart
import 'dart:math';
import 'package:flutter/material.dart';

class Estimulo {
  final int id;
  final double x;
  final double y;
  final DateTime tiempoInicio;
  final Color color;
  final bool esTarget;

  // Constructor privado
  Estimulo._({
    required this.id,
    required this.tiempoInicio,
    required this.esTarget,
    required this.color,
    required this.x,
    required this.y,
  });

  // Método estático para crear estímulos
  static Estimulo crear(
    int currentId,
    double maxWidth,
    double maxHeight,
    List<Estimulo> estimulosExistentes,
  ) {
    final random = Random().nextDouble();
    // 30% de probabilidad de ser target (ROJO) para que no sea tan fácil
    // (Ajusté tu lógica original de > 0.3 que daba 70%, a < 0.3 para que sea 30% si prefieres,
    // o lo dejamos como estaba si querías muchos rojos).
    // Tu código original decía: random > 0.3 (70% probabilidad). Lo mantengo igual.
    final esObjetivo = random > 0.3;

    double newX, newY;
    int intentos = 0;
    const maxIntentos = 50;
    const distanciaMinima = 100.0; // Distancia mínima para no superponerse

    // Algoritmo para encontrar espacio libre
    do {
      newX = Random().nextDouble() * (maxWidth - 80);
      newY =
          120 +
          Random().nextDouble() * (maxHeight - 300); // Respetando márgenes
      intentos++;
      if (intentos >= maxIntentos) break;
    } while (_haySuperposicion(
      newX,
      newY,
      estimulosExistentes,
      distanciaMinima,
    ));

    return Estimulo._(
      id: currentId,
      tiempoInicio: DateTime.now(),
      esTarget: esObjetivo,
      color: esObjetivo ? Colors.red : Colors.blue, // Rojo = Target
      x: newX,
      y: newY,
    );
  }

  static bool _haySuperposicion(
    double x,
    double y,
    List<Estimulo> existentes,
    double distanciaMinima,
  ) {
    for (var estimulo in existentes) {
      final dx = x - estimulo.x;
      final dy = y - estimulo.y;
      final distancia = sqrt(dx * dx + dy * dy);
      if (distancia < distanciaMinima) return true;
    }
    return false;
  }
}
