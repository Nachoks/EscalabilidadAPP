// Archivo: home_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:somnolence_app/core/api/api_service.dart';

enum TipoAuto { empresa, arrendado }

class HomeProvider extends ChangeNotifier {
  // Estado de UI
  bool _cargandoPatentes = false;
  bool _cargandoUbicacion = false;
  String? _direccionGuardada;

  // Datos del Formulario
  List<String> _patentesDisponibles = [];
  TipoAuto? _tipoAutoSeleccionado;
  String? _patenteSeleccionada;

  // Estado de los Tests (null = pendiente, true = aprobado, false = reprobado/obs)
  bool? _somnolenciaAprobada;
  bool? _fatigaAprobada;
  bool? _reaccionAprobada;
  bool? _checklistAprobado;
  List<dynamic>? _checklistDetalles;

  // Getters
  bool get cargandoPatentes => _cargandoPatentes;
  bool get cargandoUbicacion => _cargandoUbicacion;
  String? get direccionGuardada => _direccionGuardada;
  List<String> get patentesDisponibles => _patentesDisponibles;
  TipoAuto? get tipoAutoSeleccionado => _tipoAutoSeleccionado;
  String? get patenteSeleccionada => _patenteSeleccionada;

  bool? get somnolenciaAprobada => _somnolenciaAprobada;
  bool? get fatigaAprobada => _fatigaAprobada;
  bool? get reaccionAprobada => _reaccionAprobada;
  bool? get checklistAprobado => _checklistAprobado;

  // Constructor
  HomeProvider() {
    _cargarPatentesDesdeBD();
  }

  // Carga inicial de patentes
  Future<void> _cargarPatentesDesdeBD() async {
    print("🔍 Iniciando carga de patentes...");
    _cargandoPatentes = true;
    notifyListeners();
    try {
      final patentes = await ApiService.obtenerPatentes();
      print("✅ Patentes recibidas: $patentes");
      _patentesDisponibles = patentes;
    } catch (e) {
      print('Error al cargar patentes: $e');
    } finally {
      _cargandoPatentes = false;
      notifyListeners();
    }
  }

  // --- SETTERS (Actualizan la vista) ---

  void setTipoAuto(TipoAuto? tipo) {
    _tipoAutoSeleccionado = tipo;
    _patenteSeleccionada = null; // Reseteamos al cambiar tipo
    notifyListeners();
  }

  void setPatenteSeleccionada(String? patente) {
    _patenteSeleccionada = patente;
    notifyListeners();
  }

  void setResultadoSomnolencia(bool resultado) {
    _somnolenciaAprobada = resultado;
    notifyListeners();
  }

  void setResultadoFatiga(bool resultado) {
    _fatigaAprobada = resultado;
    notifyListeners();
  }

  void setResultadoReaccion(bool resultado) {
    _reaccionAprobada = resultado;
    notifyListeners();
  }

  void setResultadoChecklist(bool resultado, List<dynamic>? detalles) {
    _checklistAprobado = resultado;
    _checklistDetalles = detalles;
    notifyListeners();
  }

  // --- VALIDACIONES ---

  bool get todosTestsRealizados =>
      _somnolenciaAprobada != null &&
      _fatigaAprobada != null &&
      _reaccionAprobada != null &&
      _checklistAprobado != null;

  int get testsRealizadosCount {
    int count = 0;
    if (_somnolenciaAprobada != null) count++;
    if (_fatigaAprobada != null) count++;
    if (_reaccionAprobada != null) count++;
    if (_checklistAprobado != null) count++;
    return count;
  }

  bool puedeIniciarViaje(String patenteManual) {
    if (!todosTestsRealizados) return false;
    if (_tipoAutoSeleccionado == null) return false;

    if (_tipoAutoSeleccionado == TipoAuto.empresa) {
      return _patenteSeleccionada != null;
    } else {
      return patenteManual.trim().length >= 6;
    }
  }

  // --- LÓGICA PRINCIPAL: REGISTRAR VIAJE ---

  // Retorna un mapa con el resultado para que la vista muestre el SnackBar
  Future<Map<String, dynamic>> registrarInicioViaje({
    required String nombreConductor,
    required String rutConductor, // Puede ser opcional si no lo tienes
    required String patenteManual,
    required String descripcion,
  }) async {
    _cargandoUbicacion = true;
    notifyListeners();

    try {
      // 1. Obtener GPS y Dirección (Tu lógica original)
      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) throw 'El GPS está desactivado.';

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) throw 'Permisos denegados.';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String direccionTexto = "Ubicación desconocida";
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        direccionTexto =
            "${place.thoroughfare} ${place.subThoroughfare}, ${place.locality}";
      }
      _direccionGuardada = direccionTexto;

      // 2. Preparar Datos
      final DateTime ahora = DateTime.now();
      String horaFormateada =
          "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}";
      String fechaFormateada =
          "${ahora.day.toString().padLeft(2, '0')}-${ahora.month.toString().padLeft(2, '0')}-${ahora.year}";

      final String patenteFinal = _tipoAutoSeleccionado == TipoAuto.empresa
          ? _patenteSeleccionada!
          : patenteManual.trim().toUpperCase();

      final Map<String, dynamic> datosViaje = {
        'conductor': nombreConductor,
        'rut': rutConductor,
        'fecha': fechaFormateada,
        'hora': horaFormateada,
        'tipo_vehiculo': _tipoAutoSeleccionado!.name,
        'patente': patenteFinal,
        'descripcion': descripcion.isEmpty ? 'Sin descripción' : descripcion,
        'ubicacion': {
          'latitud': position.latitude,
          'longitud': position.longitude,
          'direccion': direccionTexto,
        },
        'tests': {
          'somnolencia': _somnolenciaAprobada ?? false,
          'fatiga': _fatigaAprobada ?? false,
          'reaccion': _reaccionAprobada ?? false,
          'checklist': _checklistAprobado ?? false,
          'checklist_detalle': _checklistDetalles ?? [],
        },
      };

      // 3. Enviar a Laravel (Tu lógica HTTP original)
      final url = Uri.parse('${ApiService.baseUrl}/viajes/registrar');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(datosViaje),
      );

      if (response.statusCode == 200) {
        _limpiarDespuesDeEnvio();
        return {
          'success': true,
          'message': '✅ Viaje registrado a las $horaFormateada',
        };
      } else {
        return {
          'success': false,
          'message': '❌ Error Servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    } finally {
      _cargandoUbicacion = false;
      notifyListeners();
    }
  }

  void _limpiarDespuesDeEnvio() {
    _patenteSeleccionada = null;
    _tipoAutoSeleccionado = null;
    _somnolenciaAprobada = null;
    _fatigaAprobada = null;
    _reaccionAprobada = null;
    _checklistAprobado = null;
    _checklistDetalles = null;
    _direccionGuardada = null;
    notifyListeners();
  }
}
