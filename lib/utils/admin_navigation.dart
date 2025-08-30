import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../ui/screens/admin_login_screen.dart';
import '../ui/screens/admin_screen.dart';

class AdminNavigation {
  static final AdminService _adminService = AdminService();

  /// Navigate to admin login screen
  static Future<void> navigateToLogin(BuildContext context) async {
    // Check if already authenticated
    final isLoggedIn = await _adminService.isLoggedIn();
    
    if (isLoggedIn) {
      // If already logged in, go directly to dashboard
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminScreen()),
      );
    } else {
      // Navigate to login screen
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
    }
  }

  /// Navigate to admin dashboard
  static Future<void> navigateToDashboard(BuildContext context) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AdminScreen()),
    );
  }

  /// Check if user can access admin features
  static Future<bool> canAccessAdmin() async {
    return await _adminService.isLoggedIn();
  }

  /// Logout and navigate to login
  static Future<void> logoutAndNavigateToLogin(BuildContext context) async {
    await _adminService.logout();
    
    if (context.mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
    }
  }
}

/// Mixin to add admin functionality to any screen
mixin AdminAccessMixin<T extends StatefulWidget> on State<T> {
  final AdminService _adminService = AdminService();

  /// Check authentication status
  Future<bool> checkAdminAuth() async {
    return await _adminService.isLoggedIn();
  }

  /// Show admin access dialog
  void showAdminAccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Admin Access'),
          content: const Text('Long press the header to access admin panel'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Navigate to admin with proper error handling
  Future<void> navigateToAdmin() async {
    try {
      await AdminNavigation.navigateToLogin(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing admin: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}