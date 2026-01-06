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
      final listaMapas = await ApiService.obtenerEmpresas();
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
      final exito = await ApiService.crearUsuario(datosFormulario);

      if (exito) {
        await cargarUsuarios();
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

  // ✅ NUEVO MÉTODO: Cambiar Estado (Habilitar/Deshabilitar)
  Future<bool> cambiarEstadoUsuario(int userId) async {
    try {
      // 1. Llamamos al servicio (Debes agregar este método en ApiService)
      final exito = await ApiService.cambiarEstadoUsuario(userId);

      if (exito) {
        // 2. Actualización Optimista: Actualizamos la lista localmente
        final index = _usuarios.indexWhere((u) => u.id == userId);

        if (index != -1) {
          final userViejo = _usuarios[index];

          // Creamos una copia del usuario con el estado invertido
          // (Es necesario copiar todos los campos porque User es 'final')
          _usuarios[index] = User(
            id: userViejo.id,
            nombreUsuario: userViejo.nombreUsuario,
            nombreCompleto: userViejo.nombreCompleto,
            rut: userViejo.rut,
            empresa: userViejo.empresa,
            correo: userViejo.correo,
            rol: userViejo.rol,
            roles: userViejo.roles,
            // Aquí ocurre la magia: invertimos el booleano
            estado: !userViejo.estado,
          );

          // Notificamos para que la UI se redibuje (cambie el botón y color)
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print("Error cambiando estado en provider: $e");
      return false;
    }
  }
}
