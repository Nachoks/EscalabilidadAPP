import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/presentation/providers/admin_users_provider.dart';
import 'package:somnolence_app/core/utils/roles_helper.dart';

// Widgets y Pantallas
import 'package:somnolence_app/features/admin/presentation/widgets/add_user_dialog.dart';
import 'package:somnolence_app/features/admin/presentation/screens/user_details_screen.dart';

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

class _ListaUsuariosContent extends StatefulWidget {
  const _ListaUsuariosContent();

  @override
  State<_ListaUsuariosContent> createState() => _ListaUsuariosContentState();
}

class _ListaUsuariosContentState extends State<_ListaUsuariosContent> {
  // Estado del filtro
  String _filtroSeleccionado = 'Todos';

  final List<String> _opcionesFiltro = [
    'Todos',
    'Habilitados',
    'Deshabilitados',
    'Administrador',
    'Conductor',
    'Validador',
    'Rendidor',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUsersProvider>();

    // Lógica de Filtrado
    final usuariosFiltrados = provider.usuarios.where((u) {
      if (_filtroSeleccionado == 'Todos') return true;
      if (_filtroSeleccionado == 'Habilitados') return u.estado == true;
      if (_filtroSeleccionado == 'Deshabilitados') return u.estado == false;

      return u.roles.any(
        (rol) => rol.toLowerCase().contains(_filtroSeleccionado.toLowerCase()),
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de Usuarios',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${usuariosFiltrados.length} usuarios encontrados',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          final providerActual = context.read<AdminUsersProvider>();
          showDialog(
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: providerActual,
              child: const AddUserDialog(),
            ),
          );
        },
      ),

      body: Column(
        children: [
          // 1. Dropdown Mejorado (PopupMenuButton)
          _buildFilterDropdown(),

          // 2. Lista de Usuarios
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : usuariosFiltrados.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: provider.cargarUsuarios,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: usuariosFiltrados.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final usuario = usuariosFiltrados[index];

                        // Fondo rojo suave si está deshabilitado
                        final colorFondo = usuario.estado
                            ? null
                            : Colors.red[50];

                        return Card(
                          color: colorFondo,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                decoration: usuario.estado
                                    ? null
                                    : TextDecoration.lineThrough,
                                color: usuario.estado
                                    ? Colors.black87
                                    : Colors.grey[700],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  usuario.empresa,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              final providerActual = context
                                  .read<AdminUsersProvider>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider.value(
                                        value: providerActual,
                                        child: UserDetailsScreen(user: usuario),
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ✅ WIDGET CORREGIDO: Usa PopupMenuButton para control total de posición
  Widget _buildFilterDropdown() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      // Usamos PopupMenuButton en lugar de DropdownButton
      child: PopupMenuButton<String>(
        offset: const Offset(
          0,
          50,
        ), // 🔥 CLAVE: Esto fuerza al menú a salir 50px hacia abajo
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        tooltip: 'Filtrar usuarios',
        onSelected: (String newValue) {
          setState(() {
            _filtroSeleccionado = newValue;
          });
        },
        // Construimos los items del menú
        itemBuilder: (context) => _opcionesFiltro.map((String opcion) {
          return PopupMenuItem<String>(
            value: opcion,
            child: Row(
              children: [
                if (opcion != 'Todos') ...[
                  Icon(
                    _getIconForOption(opcion),
                    size: 18,
                    color: _getColorForOption(opcion),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(opcion),
              ],
            ),
          );
        }).toList(),

        // El "Trigger" (lo que se ve antes de hacer clic)
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.filter_list_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                "Filtrar por:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 12),

              // Selección Actual
              Expanded(
                child: Row(
                  children: [
                    if (_filtroSeleccionado != 'Todos') ...[
                      Icon(
                        _getIconForOption(_filtroSeleccionado),
                        size: 18,
                        color: _getColorForOption(_filtroSeleccionado),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _filtroSeleccionado,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers para Iconos y Colores (Limpia el código) ---

  IconData _getIconForOption(String opcion) {
    if (opcion == 'Todos') return Icons.grid_view_rounded;
    if (opcion == 'Habilitados') return Icons.check_circle_outline_rounded;
    if (opcion == 'Deshabilitados') return Icons.block_rounded;
    // Si es un rol, usamos tu helper existente
    return RoleHelper.getIconForRole(opcion);
  }

  Color _getColorForOption(String opcion) {
    if (opcion == 'Todos') return Colors.grey;
    if (opcion == 'Habilitados') return Colors.green;
    if (opcion == 'Deshabilitados') return Colors.red;
    // Si es un rol, usamos tu helper existente
    return RoleHelper.getColorForRole(opcion);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No se encontraron resultados",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
