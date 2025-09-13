import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/admin/admin_service.dart';
import '../../services/admin/maintenance_service.dart';
import '../../services/admin/simple_admin_service.dart';
import 'admin_login_screen.dart';

class SimpleAdminScreen extends StatefulWidget {
  const SimpleAdminScreen({super.key});

  @override
  State<SimpleAdminScreen> createState() => _SimpleAdminScreenState();
}

class _SimpleAdminScreenState extends State<SimpleAdminScreen> {
  final AdminService _adminService = AdminService();
  final MaintenanceService _maintenanceService = MaintenanceService();
  final SimpleAdminService _simpleAdminService = SimpleAdminService();

  // Data streams
  StreamSubscription<MaintenanceStatus>? _maintenanceSubscription;
  StreamSubscription<AdminSettings>? _adminSettingsSubscription;

  // Data
  MaintenanceStatus? _maintenanceStatus;
  AdminSettings? _adminSettings;
  Map<String, int> _botTableStats = {};
  Map<String, dynamic> _vibeCheckStats = {};

  // Session management
  int _remainingSessionMinutes = 0;
  Timer? _sessionTimer;

  // UI state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _setupDataStreams();
    _startSessionTimer();
    _loadStats();
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
    // Maintenance status stream
    _maintenanceSubscription = _maintenanceService.getMaintenanceStatusStream().listen((status) {
      if (mounted) {
        setState(() {
          _maintenanceStatus = status;
          _remainingSessionMinutes = (status.remainingTime['minutes'] ?? 0);
        });
      }
    });

    // Admin settings stream
    _adminSettingsSubscription = _simpleAdminService.getAdminSettingsStream().listen((settings) {
      if (mounted) {
        setState(() {
          _adminSettings = settings;
        });
      }
    });
  }

  void _loadStats() async {
    final botStats = await _simpleAdminService.getBotTableStats();
    final vibeStats = await _simpleAdminService.getVibeCheckStats();

    if (mounted) {
      setState(() {
        _botTableStats = botStats;
        _vibeCheckStats = vibeStats;
      });
    }
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && _maintenanceStatus != null) {
        final remaining = _maintenanceStatus!.remainingTime['minutes'] ?? 0;
        setState(() {
          _remainingSessionMinutes = remaining;
        });

        if (remaining <= 0) {
          _handleSessionExpired();
        }
      }
    });
  }

  void _handleSessionExpired() async {
    await _adminService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
    }
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
                      _buildMaintenanceSection(),
                      const SizedBox(height: 24),
                      _buildReturningUsersSection(),
                      const SizedBox(height: 24),
                      _buildAnalyticsSection(),
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
                'Manage system settings and monitor analytics',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        _buildSessionTimer(),
        const SizedBox(width: 16),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildSessionTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _remainingSessionMinutes > 5
            ? const Color(0xFF10B981).withOpacity(0.1)
            : const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: _remainingSessionMinutes > 5
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 4),
          Text(
            '${_remainingSessionMinutes}m left',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _remainingSessionMinutes > 5
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
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

    return _buildSection(
      title: 'Maintenance Mode',
      icon: Icons.build,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          if (isEnabled) ...[
            const SizedBox(height: 8),
            Text(
              _maintenanceStatus?.message ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReturningUsersSection() {
    final allowReturning = _adminSettings?.allowReturningUsers ?? true;

    return _buildSection(
      title: 'Returning Users',
      icon: Icons.people,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Switch(
                value: allowReturning,
                onChanged: (value) => _toggleReturningUsers(value),
                activeColor: const Color(0xFF6366F1),
              ),
              const SizedBox(width: 12),
              Text(
                allowReturning ? 'Re-entry ALLOWED' : 'Re-entry BLOCKED',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: allowReturning ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            allowReturning
                ? 'Users can return and experience the app again'
                : 'Returning users will see "come back tomorrow" message',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return _buildSection(
      title: 'Analytics',
      icon: Icons.analytics,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Table 1 (Chaotic)',
              _botTableStats['table1Count']?.toString() ?? '0',
              Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Table 2 (Goofy)',
              _botTableStats['table2Count']?.toString() ?? '0',
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Vibe Completion Rate',
              '${(_vibeCheckStats['completionRate'] ?? 0.0).toStringAsFixed(1)}%',
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF6366F1),
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
          child,
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
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

  void _toggleReturningUsers(bool allowed) async {
    await _simpleAdminService.setReturningUsersAccess(allowed: allowed);
    _loadStats(); // Refresh stats
  }

  @override
  void dispose() {
    _maintenanceSubscription?.cancel();
    _adminSettingsSubscription?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }
}