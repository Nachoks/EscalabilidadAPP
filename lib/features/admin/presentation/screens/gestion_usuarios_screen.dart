import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/presentation/providers/admin_users_provider.dart';
import 'package:somnolence_app/core/utils/roles_helper.dart';

// IMPORTA TU NUEVO WIDGET
import 'package:somnolence_app/features/admin/presentation/widgets/add_user_dialog.dart';

class GestionUsuariosScreen extends StatelessWidget {
  const GestionUsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminUsersProvider(),
      child: const _ListaUsuariosContent(),
    );
  }
}

class _ListaUsuariosContent extends StatelessWidget {
  const _ListaUsuariosContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUsersProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Gestión de Usuarios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      // Botón flotante simplificado
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          final providerActual = context.read<AdminUsersProvider>();

          showDialog(
            context: context,
            // 2. Envolvemos el Dialog en un .value para pasarle la instancia capturada
            builder: (_) => ChangeNotifierProvider.value(
              value: providerActual,
              child: const AddUserDialog(),
            ),
          );
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.usuarios.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: provider.cargarUsuarios,
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    top: 8,
                    left: 8,
                    right: 8,
                    bottom: 80,
                  ),
                  itemCount: provider.usuarios.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 5),
                  itemBuilder: (context, index) {
                    final usuario = provider.usuarios[index];
                    return Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            usuario.nombreCompleto.isNotEmpty
                                ? usuario.nombreCompleto[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          usuario.nombreCompleto,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          usuario.empresa,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...usuario.roles.map<Widget>((rol) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Tooltip(
                                  message: rol.toString(),
                                  child: Icon(
                                    RoleHelper.getIconForRole(rol.toString()),
                                    size: 20,
                                    color: RoleHelper.getColorForRole(
                                      rol.toString(),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        onTap: () {
                          // Acción al tocar usuario
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            "No hay usuarios registrados",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
