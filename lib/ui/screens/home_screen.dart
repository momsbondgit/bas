import 'package:flutter/material.dart';
import '../widgets/confession_card.dart';
import '../widgets/status_indicator.dart';
import '../widgets/post_input.dart';
import '../../view_models/home_view_model.dart';
import '../../services/presence_service.dart';
import 'session_end_screen.dart';

class HomeScreen extends StatefulWidget {
  final int selectedFloor;
  
  const HomeScreen({
    super.key,
    required this.selectedFloor,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late HomeViewModel _viewModel;
  late AnimationController _pulseController;
  final PresenceService _presenceService = PresenceService();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _setupPulseAnimation();
    
    // Listen to ViewModel changes
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initialize();
    
    _presenceService.start();
  }

  void _onViewModelChanged() {
    if (_viewModel.isTimerExpired) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const SessionEndScreen(),
        ),
        (route) => false,
      );
    }
    setState(() {});
  }


  void _setupPulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);
  }

  void _onPostSubmitted() {
    _viewModel.onPostSubmitted();
  }

  void _handleReaction(String postId, String emoji) async {
    await _viewModel.addReaction(postId, emoji);
  }

  List<Widget> _buildPostWidgets() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    return _viewModel.posts.asMap().entries.map((entry) {
      final index = entry.key;
      final doc = entry.value;
      final data = doc.data() as Map<String, dynamic>;
      
      return Padding(
        padding: EdgeInsets.only(
          bottom: isDesktop ? 30.0 : (isTablet ? 25.0 : (screenHeight * 0.03).clamp(20.0, 28.0))
        ),
        child: ConfessionCard(
          floor: data['floor'] ?? 0,
          text: data['text'] ?? '',
          gender: data['gender'] ?? '',
          reactions: Map<String, int>.from(data['reactions'] ?? {'😂': 0, '🫢': 0, '🤪': 0}),
          isBlurred: false,
          onReaction: (emoji) => _handleReaction(doc.id, emoji),
          customAuthor: data['customAuthor'] as String?,
        ),
      );
    }).toList();
  }

  Widget _buildLockedContentOverlay() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    // Calculate approximate height of first post + padding to position overlay after it
    final firstPostHeight = 150.0; // Approximate height of a confession card
    final postBottomPadding = isDesktop ? 30.0 : (isTablet ? 25.0 : (screenHeight * 0.03).clamp(20.0, 28.0));
    final topOffset = 10.0 + firstPostHeight + postBottomPadding;
    
    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24.0 : (isTablet ? 20.0 : (screenWidth * 0.04).clamp(16.0, 20.0)),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EDEA).withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Text(
              'You not about to see all the tea without you posting. So get to it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: isDesktop ? 18.0 : (isTablet ? 16.0 : (screenWidth * 0.045).clamp(16.0, 18.0)),
                fontWeight: FontWeight.w500,
                color: Colors.black,
                letterSpacing: 0.4,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _presenceService.stop();
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    // Dynamic responsive breakpoints
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    final isMobile = !isTablet && !isDesktop;
    
    // Responsive padding calculation
    late final double horizontalPadding;
    if (isDesktop) {
      horizontalPadding = screenWidth * 0.15; // More padding on desktop
    } else if (isTablet) {
      horizontalPadding = screenWidth * 0.1; // Medium padding on tablet
    } else {
      horizontalPadding = (screenWidth * 0.055).clamp(20.0, 30.0); // Mobile padding
    }
    
    // Content max width for larger screens
    final contentMaxWidth = isDesktop ? 800.0 : (isTablet ? 600.0 : double.infinity);

    return Scaffold(
      backgroundColor: const Color(0xFFF1EDEA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(
                0, 
                isMobile && keyboardHeight > 0 ? -keyboardHeight : 0, 
                0
              ),
              child: Column(
              children: [
                // Header and feed sections - centered with max width
                Expanded(
                  child: Center(
                    child: Container(
                      width: contentMaxWidth,
                      child: Column(
                        children: [
                          // Header section
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 24.0 : (isTablet ? 20.0 : screenWidth * 0.05),
                              vertical: isDesktop ? 20.0 : (isTablet ? 18.0 : (screenHeight * 0.015).clamp(12.0, 18.0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title only
                                Text(
                                  'SAY WHAT YOU REALLY WANNA SAY 🫢🤫😬',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontSize: isDesktop ? 18.0 : (isTablet ? 16.0 : (screenWidth * 0.038).clamp(14.0, 16.0)),
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    letterSpacing: isDesktop ? 0.6 : (isTablet ? 0.55 : 0.5),
                                    height: isDesktop ? 1.2 : (isTablet ? 1.15 : 1.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Main content area - confession feed section
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 24.0 : (isTablet ? 20.0 : screenWidth * 0.05)
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1EDEA),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF818181),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Status indicators row - now inside the box
                                  Padding(
                                    padding: EdgeInsets.all(
                                      isDesktop ? 24.0 : (isTablet ? 20.0 : (screenWidth * 0.04).clamp(16.0, 20.0))
                                    ),
                                    child: Row(
                                      children: [
                                        // Only show timer if there's time remaining
                                        if (_viewModel.shouldShowTimer)
                                          StatusIndicator.timer('${_viewModel.remainingMinutes.toString().padLeft(2, '0')}:${_viewModel.remainingSeconds.toString().padLeft(2, '0')}'),
                                        const Spacer(),
                                        AnimatedBuilder(
                                          animation: _pulseController,
                                          builder: (context, child) {
                                            return StatusIndicator.liveWithPulse(_pulseController.value);
                                          },
                                        ),
                                        SizedBox(width: isDesktop ? 15.0 : (isTablet ? 12.0 : (screenWidth * 0.025).clamp(8.0, 12.0))),
                                        StatusIndicator.viewerCount(_viewModel.viewerCount),
                                      ],
                                    ),
                                  ),
                                  
                                  // Confession feed
                                  Expanded(
                                    child: _viewModel.posts.isEmpty
                                        ? const Center(child: CircularProgressIndicator())
                                        : Stack(
                                            children: [
                                              SingleChildScrollView(
                                                physics: (!_viewModel.hasPosted && _viewModel.posts.length > 1) 
                                                    ? const NeverScrollableScrollPhysics() 
                                                    : const AlwaysScrollableScrollPhysics(),
                                                padding: EdgeInsets.only(
                                                  left: isDesktop ? 24.0 : (isTablet ? 20.0 : (screenWidth * 0.04).clamp(16.0, 20.0)),
                                                  right: isDesktop ? 24.0 : (isTablet ? 20.0 : (screenWidth * 0.04).clamp(16.0, 20.0)),
                                                  top: 10.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Confession cards
                                                    ..._buildPostWidgets(),
                                                    
                                                    SizedBox(height: isDesktop ? 50.0 : (isTablet ? 40.0 : (screenHeight * 0.06).clamp(30.0, 45.0))),
                                                  ],
                                                ),
                                              ),
                                              
                                              // Overlay for locked content
                                              if (!_viewModel.hasPosted && _viewModel.posts.length > 1)
                                                _buildLockedContentOverlay(),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // POST RULES section - positioned to align with left edge of input section
                Row(
                  children: [
                    SizedBox(width: isDesktop ? 24.0 : (isTablet ? 20.0 : screenWidth * 0.05)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: isDesktop ? 35.0 : (isTablet ? 30.0 : (screenHeight * 0.04).clamp(25.0, 35.0))),
                          
                          Text(
                            'POST RULES!',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * 0.036).clamp(13.0, 15.0)),
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              letterSpacing: isDesktop ? 0.6 : (isTablet ? 0.55 : 0.5),
                            ),
                          ),
                          
                          SizedBox(height: isDesktop ? 18.0 : (isTablet ? 16.0 : (screenHeight * 0.015).clamp(12.0, 16.0))),
                          
                          _buildRuleText('1. Be funny, embarrassing, or spicy.'),
                          SizedBox(height: isDesktop ? 12.0 : (isTablet ? 10.0 : (screenHeight * 0.01).clamp(8.0, 12.0))),
                          _buildRuleText('2. No dry posts, no capping.'),
                          SizedBox(height: isDesktop ? 12.0 : (isTablet ? 10.0 : (screenHeight * 0.01).clamp(8.0, 12.0))),
                          _buildRuleText('3. When the timer runs out, it\'s over. So hurry up.'),
                          SizedBox(height: isDesktop ? 12.0 : (isTablet ? 10.0 : (screenHeight * 0.01).clamp(8.0, 12.0))),
                          _buildRuleText('4. Post to scroll and see all posts.'),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Post input section - at the very bottom
                PostInput(onPostSubmitted: _onPostSubmitted),
                
                SizedBox(height: isDesktop ? 20.0 : (isTablet ? 16.0 : (screenHeight * 0.015).clamp(10.0, 18.0))),
              ],
            ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildRuleText(String text) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'SF Pro',
        fontSize: isDesktop ? 14.0 : (isTablet ? 13.0 : (screenWidth * 0.033).clamp(12.0, 14.0)),
        fontWeight: FontWeight.w400,
        color: Colors.black,
        letterSpacing: isDesktop ? 0.5 : (isTablet ? 0.45 : 0.4),
        height: isDesktop ? 1.4 : (isTablet ? 1.35 : 1.3),
      ),
    );
  }
}