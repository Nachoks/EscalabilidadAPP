import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Importante para acceder al Provider
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/core/utils/roles_helper.dart';
import 'package:somnolence_app/features/auth/data/models/user_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/admin_users_provider.dart'; // ✅ Importamos el provider

class UserDetailsScreen extends StatefulWidget {
  final User user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  // Variable local para controlar el estado visualmente en esta pantalla
  late bool _esHabilitado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos con el valor que viene del usuario seleccionado
    _esHabilitado = widget.user.estado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle de Usuario', style: TextStyle()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Cabecera con Avatar y Nombre
            _buildHeader(),
            const SizedBox(height: 24),

            // 2. Tarjeta de Información Detallada
            _buildInfoCard(),
            const SizedBox(height: 30),

            // 3. Botones de Acción
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            widget.user.nombreCompleto.isNotEmpty
                ? widget.user.nombreCompleto[0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontSize: 40,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.user.nombreCompleto,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Mostrar roles como "badges"
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: widget.user.roles.map((rol) {
            return Chip(
              avatar: Icon(
                RoleHelper.getIconForRole(rol),
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                rol.toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor: RoleHelper.getColorForRole(rol),
              padding: EdgeInsets.zero,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Indicador de Estado (Badge extra opcional)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _esHabilitado
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _esHabilitado ? Colors.green : Colors.red,
            ),
          ),
          child: Text(
            _esHabilitado ? "CUENTA ACTIVA" : "CUENTA DESHABILITADA",
            style: TextStyle(
              color: _esHabilitado ? Colors.green[800] : Colors.red[800],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.business, 'Empresa', widget.user.empresa),
            const Divider(),
            _buildInfoRow(Icons.fingerprint, 'RUT', widget.user.rut),
            const Divider(),
            _buildInfoRow(Icons.email_outlined, 'Correo', widget.user.correo),
            const Divider(),
            _buildInfoRow(
              Icons.person_outline,
              'Nombre de Usuario',
              widget.user.nombreUsuario,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Definimos colores según estado
    final colorBoton = _esHabilitado ? Colors.orange[800]! : Colors.green[700]!;
    final textoBoton = _esHabilitado
        ? 'Deshabilitar Acceso'
        : 'Habilitar Acceso';
    final iconoBoton = _esHabilitado ? Icons.block : Icons.check_circle_outline;

    return Column(
      children: [
        // Botón Editar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Navegar a pantalla de edición o abrir diálogo
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar Usuario'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ✅ BOTÓN INTELIGENTE (HABILITAR/DESHABILITAR)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading
                ? null // Desactiva botón si está cargando
                : () async {
                    // 1. Mostrar Diálogo de Confirmación
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          _esHabilitado
                              ? '¿Deshabilitar Usuario?'
                              : '¿Habilitar Usuario?',
                        ),
                        content: Text(
                          _esHabilitado
                              ? 'El usuario no podrá ingresar a la aplicación hasta que sea habilitado nuevamente.'
                              : 'El usuario recuperará el acceso a la aplicación inmediatamente.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                    );

                    // 2. Si confirmó, llamar a la API
                    if (confirmar == true) {
                      setState(() => _isLoading = true);

                      // Llamada al Provider
                      final provider = context.read<AdminUsersProvider>();
                      final exito = await provider.cambiarEstadoUsuario(
                        widget.user.id,
                      );

                      setState(() => _isLoading = false);

                      if (exito) {
                        // 3. Actualizar estado local para ver el cambio visual
                        setState(() {
                          _esHabilitado = !_esHabilitado;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _esHabilitado
                                  ? 'Usuario Habilitado'
                                  : 'Usuario Deshabilitado',
                            ),
                            backgroundColor: _esHabilitado
                                ? Colors.green
                                : Colors.orange,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al cambiar el estado'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(iconoBoton),
            label: Text(_isLoading ? 'Procesando...' : textoBoton),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  colorBoton, // Mantenemos tu estilo de fondo lleno
              foregroundColor: Colors.white,
              side: BorderSide(color: colorBoton),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botón Eliminar
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Diálogo de confirmación para eliminar
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar Usuario'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.red[700]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
