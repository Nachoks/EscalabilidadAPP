// Archivo: reaccion_provider.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/reaccion_model.dart';

class ReaccionProvider extends ChangeNotifier {
  static const _duracionTest = Duration(seconds: 15);
  static const _intervaloGeneracion = Duration(milliseconds: 1200);
  static const _tiempoVidaEstimulo = Duration(milliseconds: 2000);
  static const int _umbralAprobacionMs = 650;

  Timer? _generadorTimer;
  Timer? _globalTimer;
  int _idEstimuloActual = 0;
  double _anchoMaximo = 0;
  double _altoMaximo = 0;

  final List<Estimulo> _estimulosActivos = [];
  List<Estimulo> get estimulosActivos => _estimulosActivos;

  final List<int> _tiemposReaccionValidos = [];

  String _tiempoRestante = '15.0';
  String get tiempoRestante => _tiempoRestante;

  bool _estaCorriendo = false;
  bool get estaCorriendo => _estaCorriendo;

  int _targetsGenerados = 0;
  int get targetsGenerados => _targetsGenerados;

  int _targetsTocados = 0;
  int get targetsTocados => _targetsTocados;

  int _errores = 0;
  int get errores => _errores;

  void establecerTamanoPantalla(double width, double height) {
    _anchoMaximo = width;
    _altoMaximo = height;
  }

  void iniciarTest() {
    if (_estaCorriendo || _anchoMaximo == 0) return;

    _targetsGenerados = 0;
    _targetsTocados = 0;
    _errores = 0;
    _idEstimuloActual = 0;
    _tiemposReaccionValidos.clear();
    _estimulosActivos.clear();
    _estaCorriendo = true;
    notifyListeners();

    _globalTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final restante = _duracionTest.inMilliseconds - (timer.tick * 100);
      if (restante <= 0) {
        _detenerTest();
      } else {
        _tiempoRestante = (restante / 1000).toStringAsFixed(1);
        notifyListeners();
      }
    });

    _generadorTimer = Timer.periodic(_intervaloGeneracion, (timer) {
      if (!_estaCorriendo) return;

      final nuevoEstimulo = Estimulo.crear(
        ++_idEstimuloActual,
        _anchoMaximo,
        _altoMaximo,
        _estimulosActivos,
      );

      if (nuevoEstimulo.esTarget) _targetsGenerados++;

      _estimulosActivos.add(nuevoEstimulo);
      notifyListeners();

      _programarEliminacion(nuevoEstimulo.id);
    });
  }

  void _programarEliminacion(int id) {
    Timer(_tiempoVidaEstimulo, () {
      if (!_estaCorriendo) return;

      final indice = _estimulosActivos.indexWhere((s) => s.id == id);
      if (indice != -1) {
        final estimulo = _estimulosActivos[indice];
        if (estimulo.esTarget) _errores++;
        _estimulosActivos.removeAt(indice);
        notifyListeners();
      }
    });
  }

  void manejarToqueEstimulo(int id) {
    if (!_estaCorriendo) return;

    final indice = _estimulosActivos.indexWhere((s) => s.id == id);
    if (indice == -1) return;

    final estimulo = _estimulosActivos[indice];
    final tiempoReaccion = DateTime.now()
        .difference(estimulo.tiempoInicio)
        .inMilliseconds;

    _estimulosActivos.removeAt(indice);

    if (estimulo.esTarget) {
      _targetsTocados++;
      _tiemposReaccionValidos.add(tiempoReaccion);
    } else {
      _errores++;
    }
    notifyListeners();
  }

  void _detenerTest() {
    _estaCorriendo = false;
    _generadorTimer?.cancel();
    _globalTimer?.cancel();

    _errores += _estimulosActivos.where((s) => s.esTarget).length;
    _estimulosActivos.clear();
    notifyListeners();
  }

  Map<String, dynamic> obtenerResultadosFinales() {
    double tiempoPromedio = 0.0;
    if (_tiemposReaccionValidos.isNotEmpty) {
      tiempoPromedio =
          _tiemposReaccionValidos.reduce((a, b) => a + b) /
          _tiemposReaccionValidos.length;
    }

    final eficacia = (_targetsTocados / max(_targetsGenerados, 1)) * 100;

    bool estaAprobado = false;
    if (_targetsTocados > 0 && tiempoPromedio <= _umbralAprobacionMs) {
      estaAprobado = true;
    }

    return {
      'trp': tiempoPromedio.toStringAsFixed(0),
      'eficacia': eficacia.toStringAsFixed(1),
      'errores': _errores,
      'tocados': _targetsTocados,
      'generados': _targetsGenerados,
      'aprobado': estaAprobado,
      'umbral': _umbralAprobacionMs,
    };
  }

  @override
  void dispose() {
    _generadorTimer?.cancel();
    _globalTimer?.cancel();
    super.dispose();
  }
}
