import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/maintenance_service.dart';

class AdminSystemControlsSection extends StatefulWidget {
  final MaintenanceStatus? maintenanceStatus;
  final List<QueryDocumentSnapshot> posts;
  final List<QueryDocumentSnapshot> endings;

  const AdminSystemControlsSection({
    super.key,
    required this.maintenanceStatus,
    required this.posts,
    required this.endings,
  });

  @override
  State<AdminSystemControlsSection> createState() => _AdminSystemControlsSectionState();
}

class _AdminSystemControlsSectionState extends State<AdminSystemControlsSection> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  bool _isUpdatingMaintenance = false;
  
  final TextEditingController _timerMinutesController = TextEditingController();
  final TextEditingController _extendMinutesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timerMinutesController.text = '1';
    _extendMinutesController.text = '1';
  }

  @override
  void dispose() {
    _timerMinutesController.dispose();
    _extendMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Maintenance Mode
          _buildSectionCard(
            title: 'Maintenance Mode',
            icon: Icons.build_circle,
            iconColor: const Color(0xFFEF4444),
            child: Column(
              children: [
                const SizedBox(height: 16),
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
          ),
          
          const SizedBox(height: 24),
          
          // Timer Controls
          _buildSectionCard(
            title: 'Timer Controls',
            icon: Icons.timer,
            iconColor: const Color(0xFF6366F1),
            child: Column(
              children: [
                const SizedBox(height: 16),
                
                // Start Fresh Timer
                _buildTimerControl(
                  title: 'Start Fresh Timer',
                  description: 'Reset and start a new session timer',
                  controller: _timerMinutesController,
                  buttonText: 'Start Timer',
                  buttonColor: const Color(0xFF059669),
                  onPressed: _startFreshTimer,
                  isDesktop: isDesktop,
                ),
                
                const SizedBox(height: 20),
                
                // Extend Timer
                _buildTimerControl(
                  title: 'Extend Current Timer',
                  description: 'Add time to the existing session',
                  controller: _extendMinutesController,
                  buttonText: 'Extend Timer',
                  buttonColor: const Color(0xFF6366F1),
                  onPressed: _extendTimer,
                  isDesktop: isDesktop,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // View Numbers
          _buildSectionCard(
            title: 'Phone Numbers Database',
            icon: Icons.phone,
            iconColor: const Color(0xFF059669),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total Submissions: ${widget.endings.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: widget.endings.isEmpty 
                      ? Center(
                          child: Text(
                            'No phone numbers submitted yet',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: widget.endings.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final data = widget.endings[index].data() as Map<String, dynamic>;
                            return _buildPhoneNumberItem(
                              phoneNumber: data['phone'] ?? 'N/A',
                              gender: data['gender'] ?? 'N/A',
                              floor: data['floor']?.toString() ?? 'N/A',
                              isDesktop: isDesktop,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
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
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildTimerControl({
    required String title,
    required String description,
    required TextEditingController controller,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
    required bool isDesktop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Minutes',
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneNumberItem({
    required String phoneNumber,
    required String gender,
    required String floor,
    required bool isDesktop,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF059669).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.phone, color: Color(0xFF059669), size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phoneNumber,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                'Gender: $gender • Floor: $floor',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleMaintenance(bool value) async {
    if (_isUpdatingMaintenance) return; // Prevent double-toggling
    
    setState(() => _isUpdatingMaintenance = true);
    
    try {
      await _maintenanceService.setMaintenanceMode(
        enabled: value,
        customMessage: value ? 'System maintenance in progress' : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Maintenance mode ${value ? "enabled" : "disabled"}',
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                fontFamily: 'SF Pro',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingMaintenance = false);
      }
    }
  }

  void _startFreshTimer() async {
    final minutes = int.tryParse(_timerMinutesController.text);
    if (minutes == null || minutes <= 0) {
      _showErrorSnackBar('Please enter valid minutes');
      return;
    }

    try {
      await _maintenanceService.startFreshSession(minutes: minutes);
      if (mounted) {
        _showSuccessSnackBar('Started fresh $minutes minute timer');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  void _extendTimer() async {
    final minutes = int.tryParse(_extendMinutesController.text);
    if (minutes == null || minutes <= 0) {
      _showErrorSnackBar('Please enter valid minutes');
      return;
    }

    try {
      await _maintenanceService.extendSessionTimer(additionalMinutes: minutes);
      if (mounted) {
        _showSuccessSnackBar('Extended timer by $minutes minutes');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}