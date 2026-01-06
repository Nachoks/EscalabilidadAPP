import 'package:flutter/material.dart';
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/features/admin/data/models/empresa_model.dart';
import 'package:somnolence_app/features/auth/data/models/user_model.dart';

class AdminUsersProvider extends ChangeNotifier {
  List<User> _usuarios = [];
  bool _isLoading = false;
  String? _error;

  List<User> get usuarios => _usuarios;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor que carga los usuarios al iniciarse
  AdminUsersProvider() {
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final listaMapas = await ApiService.obtenerTodosLosUsuarios();

      // Convertimos los mapas que llegan de la API a objetos User
      _usuarios = listaMapas.map((map) => User.fromJson(map)).toList();
    } catch (e) {
      _error = 'Error al cargar usuarios';
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Empresa>> getEmpresasDisponibles() async {
    try {
      // Llamamos a ApiService, él se encarga de la IP y el Token
      final listaMapas = await ApiService.obtenerEmpresas();

      // Solo convertimos los datos
      return listaMapas.map((json) => Empresa.fromJson(json)).toList();
    } catch (e) {
      print("Error en provider empresas: $e");
      return [];
    }
  }

  Future<bool> crearUsuario(Map<String, dynamic> datosFormulario) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Delegamos la conexión a ApiService
      final exito = await ApiService.crearUsuario(datosFormulario);

      if (exito) {
        await cargarUsuarios(); // Recargamos la lista si funcionó
      } else {
        _error = "No se pudo crear el usuario";
      }

      return exito;
    } catch (e) {
      print("Error en provider crear usuario: $e");
      _error = "Error de conexión";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
