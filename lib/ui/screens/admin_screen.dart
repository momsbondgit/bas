import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/admin/admin_service.dart';
import '../../services/admin/maintenance_service.dart';
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
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
                child: Center(
                  child: _buildMaintenanceSection(),
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
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
          );
        }
      },
      icon: const Icon(Icons.logout, size: 16),
      label: const Text('Logout'),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildMaintenanceSection() {
    final isEnabled = _maintenanceStatus?.isEnabled ?? false;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.build_circle,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Maintenance Mode',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Switch(
                value: isEnabled,
                onChanged: (value) => _toggleMaintenanceMode(value),
                activeColor: const Color(0xFF6366F1),
              ),
              const SizedBox(width: 12),
              Text(
                isEnabled ? 'Maintenance ON' : 'Maintenance OFF',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isEnabled ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Toggle maintenance mode to prevent users from accessing the app during updates.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMaintenanceMode(bool enabled) async {
    await _maintenanceService.setMaintenanceMode(enabled: enabled);
  }

  @override
  void dispose() {
    _maintenanceSubscription?.cancel();
    super.dispose();
  }
}