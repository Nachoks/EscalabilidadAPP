import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 1. CONFIGURACIÓN DE RUTAS
  static const String _urlLocal = 'http://192.168.0.25:8090/api';
  static const String _urlExterna = 'http://iaaspa.synology.me:8090/api';

  static String baseUrl = _urlExterna;

  // 2. INICIALIZACIÓN DE CONEXIÓN (Ping)
  static Future<void> inicializarConexion() async {
    print("📡 Probando conexión local con $_urlLocal...");
    try {
      await http
          .get(Uri.parse('$_urlLocal/ping'))
          .timeout(const Duration(seconds: 3));
      print("✅ Usando Local: $_urlLocal");
      baseUrl = _urlLocal;
    } catch (e) {
      print("🌍 Usando Internet: $_urlExterna");
      baseUrl = _urlExterna;
    }
  }

  // 3. LOGIN ROBUSTO
  static Future<Map<String, dynamic>> login(
    String usuario,
    String password,
  ) async {
    Future<http.Response> _hacerPeticion() {
      return http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nombre_usuario': usuario, 'password': password}),
      );
    }

    try {
      print("🔑 Conectando a: $baseUrl/login");
      http.Response response;

      try {
        response = await _hacerPeticion().timeout(const Duration(seconds: 5));
      } catch (e) {
        print("⚠️ Primer intento fallido. Reintentando...");
        response = await _hacerPeticion().timeout(const Duration(seconds: 8));
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Error: Respuesta inválida del servidor',
        };
      }

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        await prefs.setString('usuario', jsonEncode(data['usuario']));
        return {
          'success': true,
          'message': data['message'],
          'usuario': data['usuario'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Credenciales incorrectas',
        };
      }
    } catch (e) {
      print("ERROR CRÍTICO: $e");
      return {
        'success': false,
        'message': 'Error de conexión. Intenta nuevamente.',
      };
    }
  }

  // --- MÉTODOS DE AUTENTICACIÓN Y SESIÓN ---

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
      await prefs.remove('token');
      await prefs.remove('usuario');
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  static Future<Map<String, dynamic>?> getUsuarioLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioStr = prefs.getString('usuario');
    if (usuarioStr != null) return jsonDecode(usuarioStr);
    return null;
  }

  // --- MÉTODOS DE NEGOCIO ---

  static Future<List<String>> obtenerPatentes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('$baseUrl/vehiculos/patentes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerTodosLosUsuarios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Error al obtener usuarios: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  // --- Obtener Empresas para Dropdown ---
  static Future<List<dynamic>> obtenerEmpresas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Usa baseUrl dinámico (local o externo)
      final response = await http.get(
        Uri.parse('$baseUrl/admin/empresas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Retornamos la lista cruda para que el Provider la procese
        return jsonDecode(response.body);
      } else {
        print("Error API empresas: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Excepción obteniendo empresas: $e");
      return [];
    }
  }

  // --- Crear Usuario (Transacción) ---
  static Future<bool> crearUsuario(Map<String, dynamic> datos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/usuarios'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(datos),
      );

      if (response.statusCode == 201) {
        print("Usuario creado OK: ${response.body}");
        return true;
      } else {
        print(
          "Fallo al crear usuario (${response.statusCode}): ${response.body}",
        );
        return false;
      }
    } catch (e) {
      print("Excepción creando usuario: $e");
      return false;
    }
  }
}
