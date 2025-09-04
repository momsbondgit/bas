import 'package:flutter/material.dart';
import '../../../services/admin/maintenance_service.dart';
import '../../screens/maintenance_screen.dart';
import '../../screens/general_screen.dart';
import 'dart:async';

class AppInitializationWrapper extends StatefulWidget {
  const AppInitializationWrapper({super.key});

  @override
  State<AppInitializationWrapper> createState() => _AppInitializationWrapperState();
}

class _AppInitializationWrapperState extends State<AppInitializationWrapper> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  
  bool _isLoading = true;
  bool _isMaintenanceMode = false;
  String _errorMessage = '';
  StreamSubscription<MaintenanceStatus>? _maintenanceSubscription;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // TESTING: Hard code maintenance mode to false to bypass Firebase checks
      // TODO: Uncomment these lines when ready to use live maintenance mode
      // final status = await _maintenanceService.getMaintenanceStatus();
      // final isMaintenanceActive = status.isEnabled;
      
      if (mounted) {
        setState(() {
          _isMaintenanceMode = false; // Hard coded for testing
          _isLoading = false;
        });
      }

      // TESTING: Comment out real-time maintenance listener
      // TODO: Uncomment when ready to use live maintenance mode
      // _startMaintenanceListener();
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize app: $e';
          _isLoading = false;
          // Default to allowing app access if we can't check maintenance status
          _isMaintenanceMode = false;
        });
      }
    }
  }

  void _startMaintenanceListener() {
    _maintenanceSubscription = _maintenanceService
        .getMaintenanceStatusStream()
        .listen(
          (status) {
            if (mounted) {
              setState(() {
                _isMaintenanceMode = status.isEnabled;
              });
            }
          },
          onError: (error) {
            // Continue with current state on error
            // The maintenance screen has its own error handling
          },
        );
  }

  @override
  void dispose() {
    _maintenanceSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_isMaintenanceMode) {
      return const MaintenanceScreen();
    }

    return const GeneralScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EDEA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/title area
            const Text(
              'BAS Rituals',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 1.0,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              strokeWidth: 2,
            ),
            
            const SizedBox(height: 20),
            
            // Loading text
            const Text(
              'Initializing...',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
                letterSpacing: 0.3,
              ),
            ),
            
            // Error message if any
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Global maintenance mode checker for route guards
class MaintenanceModeChecker {
  static final MaintenanceService _maintenanceService = MaintenanceService();
  
  /// Check if app is in maintenance mode before navigation
  static Future<bool> isMaintenanceModeActive() async {
    try {
      final status = await _maintenanceService.getMaintenanceStatus();
      return status.isEnabled;
    } catch (e) {
      // If we can't check, allow access (fail open)
      return false;
    }
  }
  
  /// Redirect to maintenance screen if maintenance is active
  static Future<bool> checkAndRedirectIfMaintenance(BuildContext context) async {
    final isMaintenanceActive = await isMaintenanceModeActive();
    
    if (isMaintenanceActive && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MaintenanceScreen()),
        (route) => false,
      );
      return true;
    }
    
    return false;
  }
}