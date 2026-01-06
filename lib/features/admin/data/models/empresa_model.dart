class Empresa {
  final int id;
  final String nombre;

  Empresa({required this.id, required this.nombre});

  // Factory para cuando conectes tu API Laravel real
  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      // Ajusta las llaves 'id_empresa' según venga exactamente en tu JSON
      id: json['id_empresa'] is int
          ? json['id_empresa']
          : int.tryParse(json['id_empresa'].toString()) ?? 0,
      nombre:
          json['nombre_empresa'] ??
          '', // O el campo que traiga el nombre de la empresa
    );
  }
}
