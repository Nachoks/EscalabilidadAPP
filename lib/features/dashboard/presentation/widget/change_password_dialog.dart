import 'package:flutter/material.dart';
import 'package:somnolence_app/core/api/api_service.dart'; // ✅ Importar ApiService
import 'package:somnolence_app/core/constants/app_colors.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _currentPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // ✅ Variable para controlar el estado de carga
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ✅ Función para manejar el guardado
  Future<void> _guardarCambios() async {
    // 1. Validaciones básicas locales
    if (_currentPassCtrl.text.isEmpty ||
        _newPassCtrl.text.isEmpty ||
        _confirmPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Todos los campos son obligatorios"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Las nuevas contraseñas no coinciden"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Activar carga
    setState(() => _isLoading = true);

    // 3. Llamar a la API
    final resultado = await ApiService.cambiarPassword(
      _currentPassCtrl.text,
      _newPassCtrl.text,
      _confirmPassCtrl.text,
    );

    // 4. Desactivar carga (si el widget sigue montado)
    if (!mounted) return;
    setState(() => _isLoading = false);

    // 5. Manejar respuesta
    if (resultado['success']) {
      Navigator.of(context).pop(); // Cerrar diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message']),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        'Cambiar Contraseña',
        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Por seguridad, ingresa tu contraseña actual antes de crear una nueva.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            _buildPasswordField(
              controller: _currentPassCtrl,
              label: 'Contraseña Actual',
              obscureText: _obscureCurrent,
              onToggleVisibility: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 15),

            _buildPasswordField(
              controller: _newPassCtrl,
              label: 'Nueva Contraseña',
              obscureText: _obscureNew,
              onToggleVisibility: () =>
                  setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 15),

            _buildPasswordField(
              controller: _confirmPassCtrl,
              label: 'Confirmar Nueva Contraseña',
              obscureText: _obscureConfirm,
              onToggleVisibility: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          // Deshabilitar botón cancelar si está cargando
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),

        ElevatedButton(
          // ✅ Conectamos la función aquí
          onPressed: _isLoading ? null : _guardarCambios,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // ✅ Mostramos spinner si está cargando
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Actualizar'),
        ),
      ],
    );
  }

  // ... (el método _buildPasswordField se mantiene igual) ...
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}
