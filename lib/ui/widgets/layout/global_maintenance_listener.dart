import 'package:flutter/material.dart';
import '../../../services/admin/maintenance_service.dart';
import '../../../services/admin/admin_service.dart';
import '../../screens/maintenance_screen.dart';
import '../../../main.dart';
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
    // TESTING: Comment out maintenance listener to prevent Firebase maintenance checks
    // TODO: Uncomment when ready to use live maintenance mode
    // _startMaintenanceListener();
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
    
    if (!isAdmin) {
      _navigateToMaintenanceScreen();
    }
  }

  void _handleMaintenanceDisabled() async {
    final isAdmin = await _adminService.isLoggedIn();
    
    if (!isAdmin) {
      _returnToApp();
    }
  }

  void _navigateToMaintenanceScreen() {
    final navigator = MyApp.navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MaintenanceScreen()),
        (route) => false,
      );
    }
  }

  void _returnToApp() {
    final navigator = MyApp.navigatorKey.currentState;
    if (navigator != null) {
      // Clear all routes and go back to the initial app flow
      navigator.pushNamedAndRemoveUntil('/', (route) => false);
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