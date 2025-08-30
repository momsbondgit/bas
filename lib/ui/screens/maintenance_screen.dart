import 'package:flutter/material.dart';
import '../../services/maintenance_service.dart';
import '../../services/admin_service.dart';
import '../../utils/admin_navigation.dart';
import 'dart:async';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> 
    with TickerProviderStateMixin, AdminAccessMixin {
  final MaintenanceService _maintenanceService = MaintenanceService();
  final AdminService _adminService = AdminService();
  
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  
  String _maintenanceMessage = 'We\'re currently performing some maintenance. Please check back soon!';
  Timer? _statusCheckTimer;
  StreamSubscription<MaintenanceStatus>? _maintenanceSubscription;
  
  int _adminTapCount = 0;
  Timer? _adminTapTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadMaintenanceMessage();
    _startMaintenanceStatusListener();
    _startPeriodicCheck();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeController.forward();
  }

  void _loadMaintenanceMessage() async {
    try {
      final status = await _maintenanceService.getMaintenanceStatus();
      if (mounted) {
        setState(() {
          _maintenanceMessage = status.message;
        });
      }
    } catch (e) {
      // Use default message if can't fetch from Firestore
    }
  }

  void _startMaintenanceStatusListener() {
    _maintenanceSubscription = _maintenanceService
        .getMaintenanceStatusStream()
        .listen((status) async {
      if (mounted) {
        setState(() {
          _maintenanceMessage = status.message;
        });
        
        // If maintenance is disabled, check if user is admin before returning to app
        if (!status.isEnabled) {
          final isAdmin = await _adminService.isLoggedIn();
          print('[MAINTENANCE SCREEN DEBUG] Maintenance disabled - Admin status: $isAdmin');
          
          if (!isAdmin) {
            print('[MAINTENANCE SCREEN DEBUG] Non-admin user - returning to app');
            _returnToApp();
          } else {
            print('[MAINTENANCE SCREEN DEBUG] Admin user - staying on maintenance screen');
          }
        }
      }
    });
  }

  void _startPeriodicCheck() {
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final status = await _maintenanceService.getMaintenanceStatus();
        if (!status.isEnabled && mounted) {
          final isAdmin = await _adminService.isLoggedIn();
          print('[MAINTENANCE SCREEN DEBUG] Periodic check - Maintenance disabled, Admin status: $isAdmin');
          
          if (!isAdmin) {
            print('[MAINTENANCE SCREEN DEBUG] Non-admin user - periodic check returning to app');
            _returnToApp();
          } else {
            print('[MAINTENANCE SCREEN DEBUG] Admin user - periodic check staying on maintenance screen');
          }
        }
      } catch (e) {
        // Continue checking even if individual checks fail
      }
    });
  }

  void _returnToApp() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _onScreenTap() {
    _adminTapCount++;
    
    // Reset tap counter after 3 seconds of inactivity
    _adminTapTimer?.cancel();
    _adminTapTimer = Timer(const Duration(seconds: 3), () {
      _adminTapCount = 0;
    });

    // Show admin access after 7 taps
    if (_adminTapCount >= 7) {
      _adminTapCount = 0;
      _adminTapTimer?.cancel();
      _showAdminAccess();
    }
  }

  void _showAdminAccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF1EDEA),
          title: const Text(
            'Admin Access',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Access admin panel to manage maintenance mode?',
            style: TextStyle(
              fontFamily: 'SF Pro',
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  color: Color(0xFF666666),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                navigateToAdmin();
              },
              child: const Text(
                'Admin Panel',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _statusCheckTimer?.cancel();
    _maintenanceSubscription?.cancel();
    _adminTapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;
    
    // Responsive dimensions
    final horizontalPadding = isDesktop ? screenWidth * 0.15 : (isTablet ? screenWidth * 0.12 : screenWidth * 0.06);
    final iconSize = isDesktop ? 140.0 : (isTablet ? 120.0 : (screenWidth * 0.2).clamp(70.0, 100.0));
    
    // Font sizes
    final errorCodeFontSize = isDesktop ? 140.0 : (isTablet ? 120.0 : (screenWidth * 0.22).clamp(60.0, 100.0));
    final titleFontSize = isDesktop ? 36.0 : (isTablet ? 32.0 : (screenWidth * 0.065).clamp(20.0, 28.0));
    final messageFontSize = isDesktop ? 20.0 : (isTablet ? 18.0 : (screenWidth * 0.04).clamp(14.0, 16.0));

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onScreenTap,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 700.0 : (isTablet ? 500.0 : double.infinity),
                  minHeight: screenHeight * 0.8,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isMobile ? screenHeight * 0.08 : screenHeight * 0.05,
                ),
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Locked emoji
                      Text(
                        '🔒',
                        style: TextStyle(
                          fontSize: errorCodeFontSize,
                          height: 1.0,
                        ),
                      ),
                      
                      SizedBox(height: isMobile ? screenHeight * 0.05 : screenHeight * 0.04),
                      
                      // Title
                      Text(
                        'This site is now locked.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                      ),
                      
                      SizedBox(height: isMobile ? screenHeight * 0.04 : screenHeight * 0.03),
                      
                      // Maintenance message
                      Text(
                        'If you know, you know. Wait for the next invite.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: messageFontSize,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFCCCCCC),
                          letterSpacing: 0.3,
                          height: 1.5,
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.08),
                      
                      // Hidden admin hint (very subtle)
                      Text(
                        'Tap screen 7 times for system access',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.1),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}