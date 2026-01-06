import 'package:flutter/material.dart';

class RoleHelper {
  static IconData getIconForRole(String roleName) {
    final role = roleName.toLowerCase().trim();
    if (role.contains('admin')) return Icons.admin_panel_settings;
    if (role.contains('supervisor'))
      return Icons.remove_red_eye; // o Icons.visibility
    if (role.contains('conductor')) return Icons.directions_car;
    return Icons.person;
  }

  // Opcional: Si quieres colores distintos
  static Color getColorForRole(String roleName) {
    final role = roleName.toLowerCase().trim();
    if (role.contains('admin')) return Colors.red[700]!;
    if (role.contains('supervisor')) return Colors.blue[700]!;
    if (role.contains('conductor')) return Colors.green[700]!;
    return Colors.grey[600]!;
  }
}
