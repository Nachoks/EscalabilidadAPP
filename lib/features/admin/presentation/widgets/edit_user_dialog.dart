import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/core/utils/roles_helper.dart';
import 'package:somnolence_app/features/auth/data/models/user_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/admin_users_provider.dart';

class EditUserDialog extends StatefulWidget {
  final User user;
  const EditUserDialog({super.key, required this.user});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidoCtrl;
  late TextEditingController _rutCtrl;
  late TextEditingController _emailCtrl;
  final TextEditingController _passCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _isSaving = false; // Para deshabilitar botón mientras guarda

  // Roles
  final List<String> _rolesDisponibles = [
    'Administrador',
    'Conductor',
    'Validador',
    'Rendidor',
  ];
  late Set<String> _rolesSeleccionados;

  @override
  void initState() {
    super.initState();
    // 1. Separar Nombre y Apellido
    String nombre = '';
    String apellido = '';
    final parts = widget.user.nombreCompleto.split(' ');
    if (parts.isNotEmpty) {
      nombre = parts[0];
      if (parts.length > 1) {
        apellido = parts.sublist(1).join(' ');
      }
    }

    _nombreCtrl = TextEditingController(text: nombre);
    _apellidoCtrl = TextEditingController(text: apellido);
    _rutCtrl = TextEditingController(text: widget.user.rut);
    _emailCtrl = TextEditingController(text: widget.user.correo);

    // 2. Cargar Roles Actuales
    _rolesSeleccionados = {};
    for (var rolUsuario in widget.user.roles) {
      // Normalizamos: 'admin' -> 'Administrador'
      if (rolUsuario.toLowerCase() == 'admin' ||
          rolUsuario.toLowerCase() == 'administrador') {
        _rolesSeleccionados.add('Administrador');
      } else {
        // Capitalizar: 'conductor' -> 'Conductor'
        final rolCapitalizado =
            rolUsuario[0].toUpperCase() + rolUsuario.substring(1).toLowerCase();
        if (_rolesDisponibles.contains(rolCapitalizado)) {
          _rolesSeleccionados.add(rolCapitalizado);
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _rutCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // Validador de Email
  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) return "El correo es requerido";
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return "Ingresa un correo válido";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Editar Usuario"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- DATOS PERSONALES ---
              const Text(
                "Datos Personales",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _input(_nombreCtrl, "Nombre", Icons.person)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _input(
                      _apellidoCtrl,
                      "Apellido",
                      Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _input(_rutCtrl, "RUT", Icons.badge),
              const SizedBox(height: 10),

              // Campo Correo con Validación
              TextFormField(
                controller: _emailCtrl,
                validator: _validarEmail,
                decoration: const InputDecoration(
                  labelText: "Correo",
                  prefixIcon: Icon(Icons.email, size: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),

              const SizedBox(height: 20),

              // --- ROLES ---
              const Text(
                "Roles y Permisos",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Divider(),
              if (_rolesSeleccionados.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "⚠️ Selecciona al menos un rol",
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
                    size: 20,
                  ),
                  onChanged: (bool? valor) {
                    setState(() {
                      if (valor == true) {
                        _rolesSeleccionados.add(rol);
                      } else {
                        // Evita dejarlo sin roles
                        if (_rolesSeleccionados.length > 1) {
                          _rolesSeleccionados.remove(rol);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Debe tener al menos un rol"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      }
                    });
                  },
                );
              }),

              const SizedBox(height: 20),

              // --- SEGURIDAD ---
              const Text(
                "Seguridad (Opcional)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 5),

              TextFormField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                // ✅ Validación Condicional:
                validator: (value) {
                  // Si está vacío, es válido (no cambia la clave)
                  if (value == null || value.isEmpty) return null;
                  // Si escribe algo, debe ser seguro
                  if (value.length < 6) {
                    return "Mínimo 6 caracteres";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Nueva Contraseña",
                  hintText: "Dejar vacío para mantener actual",
                  helperText: "Escribe solo si deseas cambiarla",
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _isSaving ? null : _guardarCambios,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Guardar Cambios",
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  // Widget auxiliar para inputs simples
  Widget _input(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      validator: (v) => v!.isEmpty ? "Requerido" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Future<void> _guardarCambios() async {
    // 1. Validaciones Locales
    if (!_formKey.currentState!.validate()) return;

    if (_rolesSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione al menos un rol")),
      );
      return;
    }

    setState(() => _isSaving = true); // Bloqueamos botón

    // 2. Preparar Datos
    final datos = {
      'nombre': _nombreCtrl.text.trim(),
      'apellido': _apellidoCtrl.text.trim(),
      'rut': _rutCtrl.text.trim(),
      'correo': _emailCtrl.text.trim(),
      'roles': _rolesSeleccionados.toList(),
    };

    // Solo enviamos password si el usuario escribió algo válido
    if (_passCtrl.text.isNotEmpty) {
      datos['password'] = _passCtrl.text;
    }

    final provider = Provider.of<AdminUsersProvider>(context, listen: false);

    // 3. Llamada al Backend
    final exito = await provider.editarUsuario(widget.user.id, datos);

    if (!mounted) return;

    setState(() => _isSaving = false); // Desbloqueamos

    if (exito) {
      Navigator.pop(context); // Cerramos diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Datos actualizados correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? "Error al guardar los cambios"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }
}
