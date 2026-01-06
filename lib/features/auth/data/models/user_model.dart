class User {
  final int id;
  final String nombreUsuario;
  final String nombreCompleto;
  final String rut;
  final String empresa;
  final String correo;
  final String rol;
  final List<String> roles;

  // 1. NUEVO CAMPO: Estado del usuario (true = habilitado, false = deshabilitado)
  final bool estado;

  User({
    required this.id,
    required this.nombreUsuario,
    required this.nombreCompleto,
    required this.rut,
    required this.empresa,
    required this.correo,
    required this.rol,
    required this.roles,
    // 2. AGREGAR AL CONSTRUCTOR
    required this.estado,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // ----------------------------------------------------------
    // PASO 1: Capturar la data anidada (Personal y Empresa)
    // ----------------------------------------------------------
    final personalData = json['personal'];
    final empresaData = (personalData != null) ? personalData['empresa'] : null;

    // ----------------------------------------------------------
    // PASO 2: Procesar los Roles
    // ----------------------------------------------------------
    List<String> todosLosRoles = [];

    if (json['roles'] != null && json['roles'] is List) {
      todosLosRoles = (json['roles'] as List).map((rolObj) {
        if (rolObj is Map) {
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
    } else if (todosLosRoles.contains('validador')) {
      rolPrincipal = 'validador';
    } else if (todosLosRoles.contains('rendidor')) {
      rolPrincipal = 'rendidor';
    } else if (todosLosRoles.contains('conductor')) {
      rolPrincipal = 'conductor';
    } else if (todosLosRoles.isNotEmpty) {
      rolPrincipal = todosLosRoles.first;
    }

    // ----------------------------------------------------------
    // PASO 4: Retornar el Usuario (Mapeo Final)
    // ----------------------------------------------------------
    return User(
      id: json['id_usuario'] is int
          ? json['id_usuario']
          : (int.tryParse(
                  json['id_usuario']?.toString() ??
                      json['id']?.toString() ??
                      '0',
                ) ??
                0),

      nombreUsuario: json['nombre_usuario'] ?? '',

      nombreCompleto: personalData != null
          ? (personalData['nombre_completo'] ?? 'Usuario Sin Nombre')
          : (json['nombre_usuario'] ?? 'Usuario'),

      rut: personalData != null
          ? (personalData['rut'] ?? 'Sin RUT')
          : 'Sin RUT',

      empresa: empresaData != null
          ? (empresaData['nombre_empresa'] ?? 'Sin Empresa')
          : 'Sin Empresa',

      correo: personalData != null
          ? (personalData['correo'] ?? 'Sin Correo')
          : 'Sin Correo',

      // 3. CAPTURAR EL ESTADO
      // Leemos 'estado' del JSON. Validamos si viene como bool (true) o int (1)
      estado: json['estado'] == true || json['estado'] == 1,

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
      'correo': correo,
      'rol': rol,
      'roles': roles,
      'estado': estado, // Opcional: incluirlo al serializar
    };
  }

  bool get esAdmin =>
      roles.contains('admin') || roles.contains('administrador');
  bool get esConductor => roles.contains('conductor');
  bool get esRendidor => roles.contains('rendidor');
  bool get esValidador => roles.contains('validador');
}
