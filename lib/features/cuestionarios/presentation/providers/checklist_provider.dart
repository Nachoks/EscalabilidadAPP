import 'package:flutter/material.dart';
import '../../data/models/checklist_model.dart'; // Importamos el modelo que acabamos de crear

class ChecklistProvider extends ChangeNotifier {
  // Lista privada para que nadie la modifique directamente desde fuera
  final List<CheckItem> _items = [
    CheckItem(title: 'Licencia de conducción vigente'),
    CheckItem(title: 'Cédula de identidad'),
    CheckItem(title: 'Permiso de Circulación vigente'),
    CheckItem(title: 'Certificado de Revisión Técnica'),
    CheckItem(title: 'Buen estado de neumáticos'),
    CheckItem(title: 'Luces funcionando correctamente'),
    CheckItem(title: 'Sistema de visibilidad (limpiaparabrisas, espejos)'),
    CheckItem(title: 'Extintor y botiquín de primeros auxilios'),
    CheckItem(title: 'Chaleco reflectante y/o triángulos de seguridad'),
    CheckItem(title: 'Gato y llave de ruedas'),
  ];

  // Getter para leer la lista
  List<CheckItem> get items => _items;

  // 1. Lógica: Verificar si todo está marcado
  bool get allChecked => _items.every((item) => item.isChecked);

  // 2. Lógica: Calcular progreso
  double get progress =>
      _items.where((item) => item.isChecked).length / _items.length;

  // 3. Acción: Marcar o desmarcar un item
  void toggleItem(int index, bool value) {
    _items[index].isChecked = value;
    notifyListeners(); // ¡Esto avisa a la pantalla que se actualice!
  }

  // 4. Preparar datos para enviar
  Map<String, dynamic> getDataForSubmit() {
    List<Map<String, dynamic>> detalle = _items.map((item) {
      return {'item': item.title, 'marcado': item.isChecked};
    }).toList();

    return {'aprobado': allChecked, 'detalles': detalle};
  }
}
