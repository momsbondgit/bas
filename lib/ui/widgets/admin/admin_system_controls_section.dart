import 'package:flutter/material.dart';
import '../../../services/admin/maintenance_service.dart';

class AdminSystemControlsSection extends StatefulWidget {
  final MaintenanceStatus? maintenanceStatus;

  const AdminSystemControlsSection({
    super.key,
    required this.maintenanceStatus,
  });

  @override
  State<AdminSystemControlsSection> createState() => _AdminSystemControlsSectionState();
}

class _AdminSystemControlsSectionState extends State<AdminSystemControlsSection> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  bool _isUpdatingMaintenance = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Maintenance Toggle
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.maintenanceStatus?.isEnabled == true
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF059669),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.maintenanceStatus?.isEnabled == true ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.maintenanceStatus?.isEnabled == true
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: widget.maintenanceStatus?.isEnabled ?? false,
                onChanged: _isUpdatingMaintenance ? null : _toggleMaintenance,
                activeColor: const Color(0xFF6366F1),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            'Toggle maintenance mode to prevent users from accessing the app during updates.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMaintenance(bool value) async {
    if (_isUpdatingMaintenance) return;

    setState(() => _isUpdatingMaintenance = true);

    try {
      await _maintenanceService.setMaintenanceMode(enabled: value);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Maintenance mode ${value ? "enabled" : "disabled"}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingMaintenance = false);
      }
    }
  }
}