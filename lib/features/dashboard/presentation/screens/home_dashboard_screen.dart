import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/utils/roles_helper.dart';
import 'package:somnolence_app/features/admin/presentation/screens/gestion_usuarios_screen.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:somnolence_app/features/auth/presentation/screens/login_screen.dart';
import 'package:somnolence_app/core/widgets/logo_appbar.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/dashboard/presentation/screens/perfil_screen.dart';
import 'control_salida_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    // Ya no definimos colores aquí, usamos AppColors.primary

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool esConductor = user.esConductor;
    final bool esAdmin = user.esAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menú Principal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary, // ✅ USANDO CONSTANTE
        foregroundColor: AppColors.textWhite,
        leading: const LogoAppbar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background, // ✅ USANDO CONSTANTE
      body: Column(
        children: [
          // --- HEADER USUARIO ---
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: const BoxDecoration(
              // const porque el color es constante
              color: AppColors.primary, // ✅ USANDO CONSTANTE
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const Text(
                  "Bienvenido,",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  user.nombreCompleto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // --- SECCIÓN DE ICONOS DE ROLES ---
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: user.roles.map((rol) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Tooltip(
                          message: rol.toUpperCase(),
                          triggerMode: TooltipTriggerMode.tap,
                          child: Icon(
                            RoleHelper.getIconForRole(rol), // ✅ USANDO HELPER
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // --- GRID DE BOTONES ---
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              children: [
                _DashboardButton(
                  title: "Mi Perfil",
                  icon: Icons.person,
                  color: Colors.orange,
                  onTap: () {
                    // ✅ CONEXIÓN LISTA
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PerfilScreen(),
                      ),
                    );
                  },
                ),
                if (esConductor)
                  _DashboardButton(
                    title: "Control de Salida",
                    icon: Icons.directions_car,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ControlSalidaScreen(),
                        ),
                      );
                    },
                  ),

                if (esAdmin)
                  _DashboardButton(
                    title: "Gestión Usuarios",
                    icon: Icons.manage_accounts,
                    color: const Color.fromARGB(255, 88, 65, 11),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GestionUsuariosScreen(),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _DashboardButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 30,
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
