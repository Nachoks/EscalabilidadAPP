class User {
  final int id;
  final String nombreUsuario;
  final String nombreCompleto;
  final String rut;
  final String empresa;
  final String rol;
  final List<String> roles;

  User({
    required this.id,
    required this.nombreUsuario,
    required this.nombreCompleto,
    required this.rut,
    required this.empresa,
    required this.rol,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // ----------------------------------------------------------
    // PASO 1: Capturar la data anidada (Personal y Empresa)
    // ----------------------------------------------------------
    // Laravel envía esto dentro de la llave "personal"
    final personalData = json['personal'];

    // Y la empresa está dentro de personal -> empresa
    final empresaData = (personalData != null) ? personalData['empresa'] : null;

    // ----------------------------------------------------------
    // PASO 2: Procesar los Roles (Ajustado para objetos Laravel)
    // ----------------------------------------------------------
    List<String> todosLosRoles = [];

    if (json['roles'] != null && json['roles'] is List) {
      todosLosRoles = (json['roles'] as List).map((rolObj) {
        if (rolObj is Map) {
          // ✅ CORRECCIÓN: Usamos el nombre exacto de tu columna en la BD
          return (rolObj['tipo_usuario'] ?? '').toString().toLowerCase();
        }
        return rolObj.toString().toLowerCase();
      }).toList();
    } else if (json['rol'] != null) {
      todosLosRoles.add(json['rol'].toString().toLowerCase());
    }

    // ----------------------------------------------------------
    // PASO 3: Determinar Rol Principal
    // ----------------------------------------------------------
    String rolPrincipal = 'conductor';

    if (todosLosRoles.contains('admin') ||
        todosLosRoles.contains('administrador')) {
      rolPrincipal = 'admin';
    } else if (todosLosRoles.contains('supervisor')) {
      rolPrincipal = 'supervisor';
    } else if (todosLosRoles.contains('conductor')) {
      rolPrincipal = 'conductor';
    } else if (todosLosRoles.isNotEmpty) {
      rolPrincipal = todosLosRoles.first;
    }

    // ----------------------------------------------------------
    // PASO 4: Retornar el Usuario (Mapeo Final)
    // ----------------------------------------------------------
    return User(
      // Tu API usa 'id_usuario', pero por si acaso dejamos fallback a 'id'
      id: json['id_usuario'] is int
          ? json['id_usuario']
          : (int.tryParse(
                  json['id_usuario']?.toString() ??
                      json['id']?.toString() ??
                      '0',
                ) ??
                0),

      nombreUsuario: json['nombre_usuario'] ?? '',

      // ✅ CORRECCIÓN: Buscamos dentro de 'personalData', no en la raíz
      nombreCompleto: personalData != null
          ? (personalData['nombre_completo'] ?? 'Usuario Sin Nombre')
          : (json['nombre_usuario'] ?? 'Usuario'),

      // ✅ CORRECCIÓN: Rut vive dentro de personal
      rut: personalData != null
          ? (personalData['rut'] ?? 'Sin RUT')
          : 'Sin RUT',

      // ✅ CORRECCIÓN: Empresa vive dentro de empresaData
      empresa: empresaData != null
          ? (empresaData['nombre_empresa'] ??
                'Sin Empresa') // Asegúrate que el campo JSON sea 'nombre_empresa'
          : 'Sin Empresa',

      rol: rolPrincipal,
      roles: todosLosRoles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_usuario': nombreUsuario,
      'nombre_completo': nombreCompleto,
      'rut': rut,
      'empresa': empresa,
      'rol': rol,
      'roles': roles,
    };
  }

  bool get esAdmin =>
      roles.contains('admin') || roles.contains('administrador');
  bool get esSupervisor => roles.contains('supervisor');
  bool get esConductor => roles.contains('conductor');
}
