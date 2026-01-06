import 'package:flutter/material.dart';

class RoleHelper {
  static IconData getIconForRole(String roleName) {
    final role = roleName.toLowerCase().trim();

    if (role.contains('admin')) return Icons.admin_panel_settings;
    if (role.contains('conductor')) return Icons.directions_car;
    if (role.contains('rendidor')) return Icons.analytics_outlined;
    if (role.contains('validador')) return Icons.fact_check_outlined;

    return Icons.person; // Default
  }

  static Color getColorForRole(String roleName) {
    final role = roleName.toLowerCase().trim();

    if (role.contains('admin')) return Colors.red[700]!;
    if (role.contains('conductor')) return Colors.green[700]!;
    if (role.contains('rendidor')) return Colors.orange[700]!;
    if (role.contains('validador')) return Colors.purple[700]!;

    return Colors.grey[600]!;
  }
}
