import 'package:flutter/material.dart';
import '../../services/maintenance_service.dart';
import '../../services/admin_service.dart';
import '../screens/maintenance_screen.dart';
import '../../main.dart';
import 'dart:async';

class GlobalMaintenanceListener extends StatefulWidget {
  final Widget child;
  
  const GlobalMaintenanceListener({
    super.key,
    required this.child,
  });

  @override
  State<GlobalMaintenanceListener> createState() => _GlobalMaintenanceListenerState();
}

class _GlobalMaintenanceListenerState extends State<GlobalMaintenanceListener> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  final AdminService _adminService = AdminService();
  StreamSubscription<MaintenanceStatus>? _maintenanceSubscription;
  bool _isInMaintenanceMode = false;

  @override
  void initState() {
    super.initState();
    _startMaintenanceListener();
  }

  void _startMaintenanceListener() {
    _maintenanceSubscription = _maintenanceService
        .getMaintenanceStatusStream()
        .listen((status) {
      if (mounted) {
        final wasInMaintenance = _isInMaintenanceMode;
        final isNowInMaintenance = status.isEnabled;
        
        setState(() {
          _isInMaintenanceMode = isNowInMaintenance;
        });
        
        print('[MAINTENANCE DEBUG] State changed - Was in maintenance: $wasInMaintenance, Now in maintenance: $isNowInMaintenance');

        // If maintenance was just enabled, navigate to maintenance screen
        if (!wasInMaintenance && isNowInMaintenance) {
          _handleMaintenanceEnabled();
        }
        // If maintenance was just disabled, return to app
        else if (wasInMaintenance && !isNowInMaintenance) {
          _handleMaintenanceDisabled();
        }
      }
    });
  }

  void _handleMaintenanceEnabled() async {
    final isAdmin = await _adminService.isLoggedIn();
    print('[MAINTENANCE DEBUG] Maintenance enabled - Admin status: $isAdmin');
    
    if (!isAdmin) {
      print('[MAINTENANCE DEBUG] Non-admin user - navigating to maintenance screen');
      _navigateToMaintenanceScreen();
    } else {
      print('[MAINTENANCE DEBUG] Admin user - staying on current screen');
    }
  }

  void _handleMaintenanceDisabled() async {
    final isAdmin = await _adminService.isLoggedIn();
    print('[MAINTENANCE DEBUG] Maintenance disabled - Admin status: $isAdmin');
    
    if (!isAdmin) {
      print('[MAINTENANCE DEBUG] Non-admin user - returning to app');
      _returnToApp();
    } else {
      print('[MAINTENANCE DEBUG] Admin user - staying on current screen');
    }
  }

  void _navigateToMaintenanceScreen() {
    print('[GLOBAL MAINTENANCE DEBUG] Navigating to maintenance screen');
    final navigator = MyApp.navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MaintenanceScreen()),
        (route) => false,
      );
      print('[GLOBAL MAINTENANCE DEBUG] Navigation to maintenance screen completed');
    } else {
      print('[GLOBAL MAINTENANCE DEBUG] Navigator is null, cannot navigate to maintenance');
    }
  }

  void _returnToApp() {
    print('[GLOBAL MAINTENANCE DEBUG] Returning to app from maintenance mode');
    final navigator = MyApp.navigatorKey.currentState;
    if (navigator != null) {
      // Clear all routes and go back to the initial app flow
      navigator.pushNamedAndRemoveUntil('/', (route) => false);
      print('[GLOBAL MAINTENANCE DEBUG] Navigation completed');
    } else {
      print('[GLOBAL MAINTENANCE DEBUG] Navigator is null, cannot navigate');
    }
  }

  @override
  void dispose() {
    _maintenanceSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}