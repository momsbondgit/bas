import 'package:flutter/material.dart';
import '../../screens/admin_screen.dart';

class AdminSidebar extends StatefulWidget {
  final AdminSection currentSection;
  final bool isExpanded;
  final AnimationController animationController;
  final Function(AdminSection) onSectionChanged;
  final VoidCallback onToggleSidebar;
  final int remainingSessionMinutes;
  final VoidCallback onLogout;
  final VoidCallback onExtendSession;

  const AdminSidebar({
    super.key,
    required this.currentSection,
    required this.isExpanded,
    required this.animationController,
    required this.onSectionChanged,
    required this.onToggleSidebar,
    required this.remainingSessionMinutes,
    required this.onLogout,
    required this.onExtendSession,
  });

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768;
    final isMobile = screenWidth < 768;
    
    // Don't render sidebar on mobile - it's handled by drawer
    if (isMobile) {
      return const SizedBox.shrink();
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: widget.isExpanded 
          ? (isDesktop ? 280 : (isTablet ? 260 : 240)) 
          : (isDesktop ? 80 : 70),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: isDesktop ? 80 : (isTablet ? 70 : 60),
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : (isTablet ? 16 : 12)),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Admin icon
                Container(
                  width: isDesktop ? 40 : (isTablet ? 36 : 32),
                  height: isDesktop ? 40 : (isTablet ? 36 : 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : (isTablet ? 10 : 8)),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: isDesktop ? 20 : (isTablet ? 18 : 16),
                  ),
                ),
                if (widget.isExpanded) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Panel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          '${widget.remainingSessionMinutes}m left',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onToggleSidebar,
                  icon: Icon(
                    widget.isExpanded ? Icons.menu_open : Icons.menu,
                    color: const Color(0xFF6B7280),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Navigation
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildNavItem(
                    icon: Icons.article_outlined,
                    activeIcon: Icons.article,
                    label: 'Posts',
                    section: AdminSection.postsManagement,
                  ),
                  const SizedBox(height: 8),
                  _buildNavItem(
                    icon: Icons.add_circle_outline,
                    activeIcon: Icons.add_circle,
                    label: 'Add Post',
                    section: AdminSection.addPost,
                  ),
                  const SizedBox(height: 8),
                  _buildNavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'System',
                    section: AdminSection.systemControls,
                  ),
                ],
              ),
            ),
          ),

          // Footer actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Extend session
                _buildActionButton(
                  icon: Icons.timer_outlined,
                  label: 'Extend',
                  color: const Color(0xFF059669),
                  onPressed: widget.onExtendSession,
                ),
                const SizedBox(height: 12),
                // Logout
                _buildActionButton(
                  icon: Icons.logout_outlined,
                  label: 'Logout',
                  color: const Color(0xFFDC2626),
                  onPressed: widget.onLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required AdminSection section,
  }) {
    final isActive = widget.currentSection == section;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.onSectionChanged(section),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6366F1).withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(12),
            border: isActive 
                ? Border.all(color: const Color(0xFF6366F1).withOpacity(0.2))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 20,
                color: isActive ? const Color(0xFF6366F1) : const Color(0xFF6B7280),
              ),
              if (widget.isExpanded) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? const Color(0xFF6366F1) : const Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              if (widget.isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}