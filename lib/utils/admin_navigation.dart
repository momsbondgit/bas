import 'package:flutter/material.dart';
import '../ui/screens/admin_login_screen.dart';
import '../ui/screens/admin_screen.dart';

class AdminNavigation {
  /// Navigate to admin login screen
  static Future<void> navigateToLogin(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
    );
  }

  /// Navigate to admin dashboard
  static Future<void> navigateToDashboard(BuildContext context) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AdminScreen()),
    );
  }
}