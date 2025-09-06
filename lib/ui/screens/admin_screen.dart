import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin/admin_service.dart';
import '../../services/admin/maintenance_service.dart';
import '../../services/data/post_service.dart';
import '../widgets/admin/admin_sidebar.dart';
import '../widgets/admin/admin_posts_section.dart';
import '../widgets/admin/admin_add_post_section.dart';
import '../widgets/admin/admin_system_controls_section.dart';
import '../widgets/indicators/home_presence_counter.dart';
import '../widgets/indicators/returning_users_counter.dart';
import '../widgets/indicators/instagram_counter.dart';
import '../widgets/indicators/phone_numbers_counter.dart';
import 'admin_login_screen.dart';
import 'dart:async';

enum AdminSection {
  postsManagement,
  addPost,
  systemControls,
}

class AdminScreen extends StatefulWidget {
  final AdminSection? initialSection;
  
  const AdminScreen({
    super.key,
    this.initialSection,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with TickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final MaintenanceService _maintenanceService = MaintenanceService();
  final PostService _postService = PostService();
  
  AdminSection _currentSection = AdminSection.postsManagement;
  
  // Data streams
  StreamSubscription<QuerySnapshot>? _postsSubscription;
  StreamSubscription<QuerySnapshot>? _endingsSubscription;
  StreamSubscription<MaintenanceStatus>? _maintenanceSubscription;
  
  // Data
  List<QueryDocumentSnapshot> _posts = [];
  List<QueryDocumentSnapshot> _endings = [];
  MaintenanceStatus? _maintenanceStatus;
  
  // Session management
  int _remainingSessionMinutes = 0;
  Timer? _sessionTimer;
  
  // UI state
  bool _isLoading = true;
  bool _isSidebarExpanded = true;
  late AnimationController _sidebarAnimationController;

  @override
  void initState() {
    super.initState();
    _currentSection = widget.initialSection ?? AdminSection.postsManagement;
    _setupAnimations();
    _checkAuthentication();
    _setupDataStreams();
    _startSessionTimer();
  }

  void _setupAnimations() {
    _sidebarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    if (_isSidebarExpanded) {
      _sidebarAnimationController.value = 1.0;
    }
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
    // Posts stream
    _postsSubscription = _postService.getPostsStream().listen((snapshot) {
      if (mounted) {
        setState(() {
          _posts = snapshot.docs;
        });
      }
    });

    // Endings stream
    _endingsSubscription = FirebaseFirestore.instance
        .collection('endings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _endings = snapshot.docs;
        });
      }
    });

    // Maintenance status stream
    _maintenanceSubscription = _maintenanceService
        .getMaintenanceStatusStream()
        .listen((status) {
      if (mounted) {
        setState(() {
          _maintenanceStatus = status;
        });
      }
    });
  }

  void _startSessionTimer() {
    _updateRemainingTime();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() async {
    final minutes = await _adminService.getRemainingSessionMinutes();
    if (mounted) {
      setState(() {
        _remainingSessionMinutes = minutes;
      });
      
      if (minutes <= 0) {
        _logout();
      }
    }
  }

  void _logout() async {
    await _adminService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
    }
  }

  void _extendSession() async {
    await _adminService.extendSession();
    _updateRemainingTime();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session extended by 24 hours'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onSectionChanged(AdminSection section) {
    setState(() {
      _currentSection = section;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
    
    if (_isSidebarExpanded) {
      _sidebarAnimationController.forward();
    } else {
      _sidebarAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    _endingsSubscription?.cancel();
    _maintenanceSubscription?.cancel();
    _sessionTimer?.cancel();
    _sidebarAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF1EDEA),
      drawer: isMobile ? _buildMobileDrawer() : null,
      body: SafeArea(
        child: isMobile 
          ? _buildMobileLayout(screenWidth, screenHeight)
          : _buildDesktopLayout(screenWidth, screenHeight, isDesktop, isTablet),
      ),
    );
  }

  Widget _buildMobileLayout(double screenWidth, double screenHeight) {
    return Column(
      children: [
        // Mobile app bar
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu, color: Color(0xFF374151)),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSectionTitle(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      '${_remainingSessionMinutes}m left',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _extendSession,
                icon: const Icon(Icons.timer, color: Color(0xFF059669), size: 20),
              ),
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Color(0xFFDC2626), size: 20),
              ),
            ],
          ),
        ),
        
        // Mobile content
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Mobile stats chips
                _buildMobileStatsChips(),
                const SizedBox(height: 16),
                
                // Main content
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(double screenWidth, double screenHeight, bool isDesktop, bool isTablet) {
    return Row(
      children: [
        // Sidebar for desktop/tablet
        AdminSidebar(
          currentSection: _currentSection,
          isExpanded: _isSidebarExpanded,
          animationController: _sidebarAnimationController,
          onSectionChanged: _onSectionChanged,
          onToggleSidebar: _toggleSidebar,
          remainingSessionMinutes: _remainingSessionMinutes,
          onLogout: _logout,
          onExtendSession: _extendSession,
        ),
        
        // Main content area
        Expanded(
          child: Container(
            margin: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                
                SizedBox(height: isDesktop ? 24 : 16),
                
                // Main content
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
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
                          '${_remainingSessionMinutes}m left',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMobileNavItem(
                      icon: Icons.article_outlined,
                      activeIcon: Icons.article,
                      label: 'Posts Management',
                      section: AdminSection.postsManagement,
                    ),
                    const SizedBox(height: 8),
                    _buildMobileNavItem(
                      icon: Icons.add_circle_outline,
                      activeIcon: Icons.add_circle,
                      label: 'Add Post',
                      section: AdminSection.addPost,
                    ),
                    const SizedBox(height: 8),
                    _buildMobileNavItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings,
                      label: 'System Controls',
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
                  top: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Column(
                children: [
                  _buildMobileActionButton(
                    icon: Icons.timer_outlined,
                    label: 'Extend Session',
                    color: const Color(0xFF059669),
                    onPressed: _extendSession,
                  ),
                  const SizedBox(height: 12),
                  _buildMobileActionButton(
                    icon: Icons.logout_outlined,
                    label: 'Logout',
                    color: const Color(0xFFDC2626),
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              'Loading Admin Panel...',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768;
    
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSectionTitle(),
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 4 : 2),
                    Text(
                      _getSectionSubtitle(),
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: isDesktop ? 16 : 12),
          
          // Quick stats
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const ReturningUsersCounter(),
                const SizedBox(width: 12),
                const InstagramCounter(),
                const SizedBox(width: 12),
                const PhoneNumbersCounter(),
                const SizedBox(width: 12),
                const HomePresenceCounter(),
                if (_maintenanceStatus != null) ...[
                  const SizedBox(width: 12),
                  _buildMaintenanceIndicator(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceIndicator() {
    final isEnabled = _maintenanceStatus?.isEnabled ?? false;
    final color = isEnabled ? const Color(0xFFEF4444) : const Color(0xFF059669);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isEnabled ? 'Maintenance' : 'Online',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMainContent() {
    switch (_currentSection) {
      case AdminSection.postsManagement:
        return AdminPostsSection(
          posts: _posts,
          onPostDeleted: () {
            // Refresh handled by stream
          },
        );
      case AdminSection.addPost:
        return AdminAddPostSection(
          onPostAdded: () {
            // Refresh handled by stream
          },
        );
      case AdminSection.systemControls:
        return AdminSystemControlsSection(
          maintenanceStatus: _maintenanceStatus,
          posts: _posts,
          endings: _endings,
        );
    }
  }







  String _getSectionTitle() {
    switch (_currentSection) {
      case AdminSection.postsManagement:
        return 'Posts Management';
      case AdminSection.addPost:
        return 'Add Post';
      case AdminSection.systemControls:
        return 'System Controls';
    }
  }

  String _getSectionSubtitle() {
    switch (_currentSection) {
      case AdminSection.postsManagement:
        return 'View and manage all posts';
      case AdminSection.addPost:
        return 'Create new posts as admin';
      case AdminSection.systemControls:
        return 'Maintenance and system settings';
    }
  }

  Widget _buildMobileStatsChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const ReturningUsersCounter(),
          const SizedBox(width: 8),
          const InstagramCounter(),
          const SizedBox(width: 8),
          const PhoneNumbersCounter(),
          const SizedBox(width: 8),
          const HomePresenceCounter(),
          if (_maintenanceStatus != null) ...[
            const SizedBox(width: 8),
            _buildMaintenanceIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required AdminSection section,
  }) {
    final isActive = _currentSection == section;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _onSectionChanged(section);
          Navigator.of(context).pop(); // Close drawer
        },
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
          ),
        ),
      ),
    );
  }

  Widget _buildMobileActionButton({
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
          ),
        ),
      ),
    );
  }
}