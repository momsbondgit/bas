import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/admin/admin_service.dart';
import '../../services/admin/maintenance_service.dart';
import '../widgets/admin/admin_metrics_section.dart';
import '../widgets/admin/admin_bot_settings_section.dart';
import 'admin_login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminService _adminService = AdminService();
  final MaintenanceService _maintenanceService = MaintenanceService();

  StreamSubscription<MaintenanceStatus>? _maintenanceSubscription;
  MaintenanceStatus? _maintenanceStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _setupDataStreams();
  }

  void _checkAuthentication() async {
    final isLoggedIn = await _adminService.isLoggedIn();
    if (!isLoggedIn && mounted) {
      _navigateToLogin();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupDataStreams() {
    _maintenanceSubscription = _maintenanceService.getMaintenanceStatusStream().listen((status) {
      if (mounted) {
        setState(() {
          _maintenanceStatus = status;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const AdminMetricsSection(),
                      const SizedBox(height: 24),
                      _buildMaintenanceSection(),
                      const SizedBox(height: 24),
                      const AdminBotSettingsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.admin_panel_settings,
            color: Color(0xFF6366F1),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BAS Admin Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                'Manage system maintenance mode',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: () async {
        await _adminService.logout();
        if (mounted) {
          _navigateToLogin();
        }
      },
      icon: const Icon(Icons.logout, size: 16),
      label: const Text('Logout'),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF6B7280),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
    );
  }

  Widget _buildMaintenanceSection() {
    final isMaintenanceEnabled = _maintenanceStatus?.isEnabled ?? false;
    final isBlockingReturningUsers = _maintenanceStatus?.blockReturningUsers ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSwitchSection(
            icon: Icons.build_circle,
            iconColor: const Color(0xFFEF4444),
            title: 'Maintenance Mode',
            isEnabled: isMaintenanceEnabled,
            onChanged: _toggleMaintenanceMode,
            enabledText: 'Maintenance ON',
            disabledText: 'Maintenance OFF',
            enabledColor: const Color(0xFFEF4444),
            description: 'Prevent all users from accessing the app during updates.',
          ),
          const SizedBox(height: 32),
          _buildSwitchSection(
            icon: Icons.block,
            iconColor: const Color(0xFFF59E0B),
            title: 'Block Returning Users',
            isEnabled: isBlockingReturningUsers,
            onChanged: _toggleBlockReturningUsers,
            enabledText: 'Blocking ON',
            disabledText: 'Blocking OFF',
            enabledColor: const Color(0xFFF59E0B),
            description: 'Prevent returning users from re-entering worlds. New users can still sign up.',
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isEnabled,
    required ValueChanged<bool> onChanged,
    required String enabledText,
    required String disabledText,
    required Color enabledColor,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Switch(
              value: isEnabled,
              onChanged: onChanged,
              activeColor: const Color(0xFF6366F1),
            ),
            const SizedBox(width: 12),
            Text(
              isEnabled ? enabledText : disabledText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isEnabled ? enabledColor : const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  void _toggleMaintenanceMode(bool enabled) async {
    await _maintenanceService.setMaintenanceMode(enabled: enabled);
  }

  void _toggleBlockReturningUsers(bool enabled) async {
    await _maintenanceService.setBlockReturningUsers(enabled: enabled);
  }

  @override
  void dispose() {
    _maintenanceSubscription?.cancel();
    super.dispose();
  }
}