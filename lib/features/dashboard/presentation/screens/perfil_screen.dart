// Archivo: lib/features/perfil/presentation/screens/perfil_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart'; // Tu archivo de colores// Tu helper de roles
import 'package:somnolence_app/core/utils/roles_helper.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:somnolence_app/features/dashboard/presentation/widget/change_password_dialog.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del usuario actual
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER CON AVATAR ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      user.nombreCompleto.isNotEmpty
                          ? user.nombreCompleto[0].toUpperCase()
                          : "U",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.nombreCompleto,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- DATOS PERSONALES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildInfoCard(
                    title: "Información Personal",
                    children: [
                      _buildDataRow(
                        Icons.person,
                        "Nombre",
                        user.nombreCompleto,
                      ),
                      const Divider(),
                      _buildDataRow(Icons.badge, "RUT", user.rut),
                      const Divider(),
                      // ✅ NUEVO: Fila de Correo
                      _buildDataRow(
                        Icons.email_outlined,
                        "Correo",
                        user.correo,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildInfoCard(
                    title: "Información Laboral",
                    children: [
                      _buildDataRow(Icons.business, "Empresa", user.empresa),
                      const Divider(),
                      // Fila especial para los roles con iconos
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.work, color: AppColors.primary),
                            const SizedBox(width: 15),
                            const Text(
                              "Roles:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Generamos los chips de roles dinámicamente
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                children: user.roles.map((rol) {
                                  return Chip(
                                    avatar: Icon(
                                      RoleHelper.getIconForRole(rol),
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      rol.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: AppColors.secondary,
                                    padding: const EdgeInsets.all(0),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // --- BOTÓN CAMBIAR CONTRASEÑA ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Obliga a usar los botones para cerrar
                          builder: (context) => const ChangePasswordDialog(),
                        );
                      },
                      icon: const Icon(Icons.lock_reset),
                      label: const Text("Cambiar Contraseña"),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.textWhite,
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para las tarjetas blancas
  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  // Widget auxiliar para cada fila de datos
  Widget _buildDataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400]),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
