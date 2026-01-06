import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/core/utils/roles_helper.dart';
import 'package:somnolence_app/features/admin/data/models/empresa_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/admin_users_provider.dart';

// 1. IMPORTANTE: Importa tu nuevo modelo aquí
// Ajusta la ruta según donde hayas creado el archivo del Paso 1

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  // --- Controladores Personal ---
  final TextEditingController _nombrePersonalCtrl = TextEditingController();
  final TextEditingController _apellidoPersonalCtrl = TextEditingController();
  final TextEditingController _rutCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  // --- Variables Empresa ---
  int? _selectedEmpresaId;
  List<Empresa> _empresasDisponibles = [];
  bool _isLoadingEmpresas = true;

  // --- Controladores Usuario ---
  final TextEditingController _usuarioCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  // --- Variables Roles ---
  final List<String> _rolesDisponibles = [
    'Administrador',
    'Conductor',
    'Validador',
    'Rendidor',
  ];
  final Set<String> _rolesSeleccionados = {};

  @override
  void initState() {
    super.initState();
    _cargarEmpresas();
  }

  Future<void> _cargarEmpresas() async {
    // 1. Obtenemos el provider (sin escuchar cambios, solo para llamar la función)
    final provider = Provider.of<AdminUsersProvider>(context, listen: false);

    // 2. Llamamos a la función asíncrona que acabamos de crear
    // Nota: El await va AQUÍ, fuera del setState
    final listaTraida = await provider.getEmpresasDisponibles();

    // 3. Verificamos que el widget siga vivo (mounted) antes de actualizar la UI
    if (!mounted) return;

    // 4. Actualizamos la variable local del Dialog
    setState(() {
      _empresasDisponibles = listaTraida;
      _isLoadingEmpresas = false;
    });
  }

  @override
  void dispose() {
    _nombrePersonalCtrl.dispose();
    _apellidoPersonalCtrl.dispose();
    _rutCtrl.dispose();
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo Usuario'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECCIÓN: DATOS PERSONALES ---
              _buildSectionTitle("Datos Personales"),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _nombrePersonalCtrl,
                      'Nombre',
                      Icons.person,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _apellidoPersonalCtrl,
                      'Apellido',
                      Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField(_rutCtrl, 'RUT', Icons.badge),
              const SizedBox(height: 10),
              _buildTextField(_emailCtrl, 'Correo', Icons.email_outlined),
              const SizedBox(height: 10),

              // --- DROPDOWN EMPRESA ---
              _isLoadingEmpresas
                  ? const Center(child: LinearProgressIndicator())
                  : DropdownButtonFormField<int>(
                      value: _selectedEmpresaId,
                      decoration: const InputDecoration(
                        labelText: 'Empresa',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _empresasDisponibles.map((empresa) {
                        return DropdownMenuItem<int>(
                          value: empresa.id,
                          child: Text(
                            empresa.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedEmpresaId = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Seleccione una empresa' : null,
                    ),

              const SizedBox(height: 20),

              // --- SECCIÓN: CUENTA DE USUARIO ---
              _buildSectionTitle("Cuenta de Usuario"),
              const SizedBox(height: 10),
              _buildTextField(
                _usuarioCtrl,
                'Nombre de Usuario',
                Icons.account_circle,
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- SECCIÓN: ROLES ---
              _buildSectionTitle("Asignar Roles"),
              const Divider(),
              if (_rolesSeleccionados.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Selecciona al menos un rol",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              ..._rolesDisponibles.map((rol) {
                final isSelected = _rolesSeleccionados.contains(rol);
                return CheckboxListTile(
                  title: Text(rol),
                  value: isSelected,
                  activeColor: AppColors.primary,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    RoleHelper.getIconForRole(rol),
                    color: RoleHelper.getColorForRole(rol),
                  ),
                  onChanged: (bool? valor) {
                    setState(() {
                      if (valor == true)
                        _rolesSeleccionados.add(rol);
                      else
                        _rolesSeleccionados.remove(rol);
                    });
                  },
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: (_rolesSeleccionados.isEmpty || _selectedEmpresaId == null)
              ? null
              : () async {
                  // 1. Mostrar carga
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Procesando... espere')),
                  );

                  final datosFormulario = {
                    'personal': {
                      'nombre': _nombrePersonalCtrl.text,
                      'apellido': _apellidoPersonalCtrl.text,
                      'rut': _rutCtrl.text,
                      'correo': _emailCtrl.text,
                      'id_empresa': _selectedEmpresaId,
                    },
                    'usuario': {
                      'username': _usuarioCtrl.text,
                      'password': _passwordCtrl.text,
                    },
                    'roles': _rolesSeleccionados.toList(),
                  };

                  print("📤 Enviando datos: $datosFormulario");

                  final provider = Provider.of<AdminUsersProvider>(
                    context,
                    listen: false,
                  );

                  // 2. Intentar crear
                  final exito = await provider.crearUsuario(datosFormulario);

                  if (!mounted) return;

                  // 3. Manejar resultado
                  Navigator.of(context).pop(); // Cerramos el diálogo primero

                  if (exito) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Usuario creado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // Si falló, mostramos un diálogo con el error (si el provider lo guardó)
                    // OJO: Revisa tu consola para el detalle exacto si esto es genérico
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("❌ Error al Guardar"),
                        content: Text(
                          provider.error ??
                              "El servidor rechazó los datos.\n\nPosibles causas:\n1. RUT duplicado\n2. Usuario duplicado\n3. Roles mal escritos en BD",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                },
          child: const Text("Guardar Usuario"),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        fontSize: 16,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
    );
  }
}
// NOTA: La clase Empresa ha sido eliminada de aquí.