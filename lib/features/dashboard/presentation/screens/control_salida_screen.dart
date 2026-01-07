// Archivo: lib/features/dashboard/presentation/screens/control_salida_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/features/cuestionarios/presentation/screens/checklist_screen.dart';
import 'package:somnolence_app/features/evaluacion_colores/presentation/screens/reaccion_screen.dart';
import 'package:somnolence_app/features/cuestionarios/presentation/screens/fatiga_screen.dart';
import 'package:somnolence_app/features/cuestionarios/presentation/screens/somnolencia_screen.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:somnolence_app/features/auth/data/models/user_model.dart';
import '../providers/home_provider.dart';

class ControlSalidaScreen extends StatelessWidget {
  const ControlSalidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el HomeProvider específicamente para esta pantalla
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const _ControlSalidaContent(),
    );
  }
}

class _ControlSalidaContent extends StatefulWidget {
  const _ControlSalidaContent();

  @override
  State<_ControlSalidaContent> createState() => _ControlSalidaContentState();
}

class _ControlSalidaContentState extends State<_ControlSalidaContent> {
  final _patenteArrendadoController = TextEditingController();
  final _descripcionController = TextEditingController();

  final Color _primaryColor = const Color(0xFFF35F34);
  final Color _secondaryColor = const Color.fromARGB(255, 185, 120, 104);

  @override
  void dispose() {
    _patenteArrendadoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE BOTONES (UI) ---

  void _handleRegistrarViaje() async {
    final homeProvider = context.read<HomeProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no identificado')),
      );
      return;
    }

    // Llamamos al provider para hacer el trabajo sucio
    final resultado = await homeProvider.registrarInicioViaje(
      nombreConductor: user.nombreUsuario,
      rutConductor: user.rut,
      patenteManual: _patenteArrendadoController.text,
      descripcion: _descripcionController.text,
    );

    if (!mounted) return;

    // Manejo de respuesta visual
    if (resultado['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message']),
          backgroundColor: Colors.green,
        ),
      );

      _patenteArrendadoController.clear();
      _descripcionController.clear();

      // NUEVO: Volvemos al menú principal tras el éxito
      Navigator.pop(context);
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
    // 1. OBTENEMOS EL USUARIO DESDE EL AUTH PROVIDER
    final user = context.watch<AuthProvider>().currentUser;
    // 2. OBTENEMOS EL ESTADO DEL HOME
    final homeProvider = context.watch<HomeProvider>();

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Control de Salida', // CAMBIO DE TÍTULO
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        // QUITAMOS el botón de logout de aquí
        actions: [],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryColor, _secondaryColor],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            child: Column(
              children: [
                _buildHeaderInfo(user, homeProvider),

                const SizedBox(height: 24),
                _buildProgressSection(homeProvider),

                const SizedBox(height: 24),
                _buildTestsList(homeProvider),

                const SizedBox(height: 32),
                _buildMainActionButton(homeProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES (Sin cambios mayores, solo copiados) ---

  Widget _buildHeaderInfo(User user, HomeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Puedes mantener los datos del usuario aquí para confirmar quién llena el formulario
          Icon(
            Icons.assignment_ind_outlined,
            size: 48,
            color: _primaryColor,
          ), // Icono cambiado ligeramente
          const SizedBox(height: 10),

          Text(
            user.nombreCompleto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          Text(
            user.rut,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const Divider(height: 30),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Seleccione tipo de vehículo:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildVehicleOption(
                  provider,
                  'Empresa',
                  Icons.business_rounded,
                  TipoAuto.empresa,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildVehicleOption(
                  provider,
                  'Arrendado',
                  Icons.car_rental,
                  TipoAuto.arrendado,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (provider.tipoAutoSeleccionado == TipoAuto.empresa)
            _buildDropdownPatentes(provider)
          else if (provider.tipoAutoSeleccionado == TipoAuto.arrendado)
            _buildInputPatenteArrendada(provider),

          if (provider.tipoAutoSeleccionado != null) ...[
            const SizedBox(height: 15),
            TextField(
              controller: _descripcionController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Descripción (Opcional)',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],

          if (provider.direccionGuardada != null) ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                "📍 Inicio: ${provider.direccionGuardada}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleOption(
    HomeProvider provider,
    String label,
    IconData icon,
    TipoAuto value,
  ) {
    bool selected = provider.tipoAutoSeleccionado == value;
    return GestureDetector(
      onTap: () {
        provider.setTipoAuto(value);
        _patenteArrendadoController.clear();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _primaryColor : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? _primaryColor : Colors.grey.shade400),
            Text(
              label,
              style: TextStyle(
                color: selected ? _primaryColor : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownPatentes(HomeProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: provider.cargandoPatentes
              ? const Text('Cargando...')
              : const Text('Seleccionar patente'),
          value: provider.patenteSeleccionada,
          items: provider.patentesDisponibles
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (val) => provider.setPatenteSeleccionada(val),
        ),
      ),
    );
  }

  Widget _buildInputPatenteArrendada(HomeProvider provider) {
    return TextField(
      controller: _patenteArrendadoController,
      onChanged: (_) => setState(() {}),
      textCapitalization: TextCapitalization.characters,
      maxLength: 6,
      decoration: InputDecoration(
        hintText: 'Ej: ABCD12',
        counterText: '',
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildProgressSection(HomeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso de Tests',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${provider.testsRealizadosCount}/4',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: provider.todosTestsRealizados
                      ? Colors.green
                      : _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: provider.testsRealizadosCount / 4,
            backgroundColor: Colors.grey.shade200,
            color: provider.todosTestsRealizados ? Colors.green : _primaryColor,
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTestsList(HomeProvider provider) {
    return Column(
      children: [
        _buildTestButton(
          'Test Somnolencia',
          provider.somnolenciaAprobada,
          () async {
            final res = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SomnolenciaScreen()),
            );
            if (res is bool) provider.setResultadoSomnolencia(res);
          },
        ),
        const SizedBox(height: 16),
        _buildTestButton('Test Fatiga', provider.fatigaAprobada, () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FatigaScreen()),
          );
          if (res is bool) provider.setResultadoFatiga(res);
        }),
        const SizedBox(height: 16),
        _buildTestButton('Test Reacción', provider.reaccionAprobada, () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReaccionScreen()),
          );
          if (res is bool) provider.setResultadoReaccion(res);
        }),
        const SizedBox(height: 16),
        _buildTestButton(
          'Checklist de Ruta',
          provider.checklistAprobado,
          () async {
            final res = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChecklistScreen()),
            );
            if (res is Map<String, dynamic>) {
              provider.setResultadoChecklist(res['aprobado'], res['detalles']);
            } else if (res is bool) {
              provider.setResultadoChecklist(res, null);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTestButton(String text, bool? status, VoidCallback onTap) {
    Color color = status == null
        ? _primaryColor
        : (status ? Colors.green : Colors.orange);
    IconData icon = status == null
        ? Icons.arrow_forward_rounded
        : (status ? Icons.check_circle : Icons.warning_amber_rounded);
    String finalText = status == true
        ? '$text ✓'
        : (status == false ? '$text ⚠' : text);

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: status != null ? color : null,
        gradient: status == null
            ? LinearGradient(colors: [_primaryColor, _secondaryColor])
            : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              finalText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionButton(HomeProvider provider) {
    bool habilitado = provider.puedeIniciarViaje(
      _patenteArrendadoController.text,
    );
    return Opacity(
      opacity: (habilitado && !provider.cargandoUbicacion) ? 1.0 : 0.5,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007BFF), Color.fromARGB(255, 84, 143, 206)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: (habilitado && !provider.cargandoUbicacion)
              ? _handleRegistrarViaje
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: provider.cargandoUbicacion
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Registrar Inicio del Viaje',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
