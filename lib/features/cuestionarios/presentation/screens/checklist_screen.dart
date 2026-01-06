// Archivo: checklist_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Necesitas el paquete provider
import '../providers/checklist_provider.dart';
import '../../data/models/checklist_model.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el Provider solo para esta pantalla
    return ChangeNotifierProvider(
      create: (_) => ChecklistProvider(),
      child: const _ChecklistContent(),
    );
  }
}

class _ChecklistContent extends StatelessWidget {
  const _ChecklistContent();

  @override
  Widget build(BuildContext context) {
    // Obtenemos el provider para leer datos
    final provider = context.watch<ChecklistProvider>();

    void submitForm() {
      // Usamos el provider para obtener los datos limpios
      final data = provider.getDataForSubmit();
      final allChecked = provider.allChecked;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            allChecked
                ? '¡Verificación completa!'
                : 'Guardando con observaciones...',
          ),
          backgroundColor: allChecked ? Colors.green : Colors.orange,
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          Navigator.pop(context, data);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist Pre-Ruta'),
        backgroundColor: const Color(0xFFF35F34),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- BARRA DE PROGRESO ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Estado de verificación",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${(provider.progress * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: provider.allChecked
                            ? Colors.green
                            : Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: provider.progress,
                  backgroundColor: Colors.grey[200],
                  color: provider.allChecked ? Colors.green : Colors.blueAccent,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                if (!provider.allChecked)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Nota: Los ítems no marcados se registrarán como pendientes.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // --- LISTA DE CHECKBOXES ---
          Expanded(
            child: ListView.separated(
              itemCount: provider.items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                CheckItem item = provider.items[index];
                return CheckboxListTile(
                  title: Text(item.title),
                  value: item.isChecked,
                  activeColor: Colors.green,
                  // Aquí llamamos a la lógica del provider
                  onChanged: (bool? value) {
                    context.read<ChecklistProvider>().toggleItem(
                      index,
                      value ?? false,
                    );
                  },
                );
              },
            ),
          ),

          // --- BOTÓN DE CONTINUAR ---
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.allChecked
                          ? const Color(0xFFF35F34)
                          : Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      provider.allChecked
                          ? 'CONFIRMAR Y VOLVER'
                          : 'CONFIRMAR CON OBSERVACIONES',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
