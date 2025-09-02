import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/confession_card.dart';
import '../widgets/status_indicator.dart';
import '../../view_models/home_view_model.dart';
import '../../services/presence_service.dart';
import 'session_end_screen.dart';

void main() => runApp(MaterialApp(home: GirlMeetsCollegeScreen(selectedFloor: 1)));

class GirlMeetsCollegeScreen extends StatefulWidget {
  final int selectedFloor;
  
  const GirlMeetsCollegeScreen({
    super.key,
    required this.selectedFloor,
  });

  @override
  State<GirlMeetsCollegeScreen> createState() => _GirlMeetsCollegeScreenState();
}

class _GirlMeetsCollegeScreenState extends State<GirlMeetsCollegeScreen> with TickerProviderStateMixin {
  late HomeViewModel _viewModel;
  late AnimationController _pulseController;
  final PresenceService _presenceService = PresenceService();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _setupPulseAnimation();
    
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
    return _viewModel.posts.asMap().entries.map((entry) {
      final index = entry.key;
      final doc = entry.value;
      final data = doc.data() as Map<String, dynamic>;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: ConfessionCard(
          floor: data['floor'] ?? 0,
          text: data['text'] ?? '',
          gender: data['gender'] ?? '',
          reactions: Map<String, int>.from(data['reactions'] ?? {'🤭': 0, '☠️': 0, '🤪': 0}),
          isBlurred: false,
          onReaction: (emoji) => _handleReaction(doc.id, emoji),
          customAuthor: data['customAuthor'] as String?,
        ),
      );
    }).toList();
  }

  Widget _buildLockedContentOverlay() {
    return Positioned(
      top: 140,
      left: 0,
      right: 0,
      bottom: 90,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 17),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF9).withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Text(
              'You not about to see all the tea without you posting. So get to it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16.0,
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF9),
      body: Stack(
        children: [
          _buildFadeBackground(context),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                _buildTitle(),
                const SizedBox(height: 35),
                _buildTeaTopicSection(),
                const Spacer(),
                _buildVibeSection(),
                const SizedBox(height: 20),
                _buildBottomInput(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildLiveStreamElements(),
          _buildChatArea(),
        ],
      ),
    );
  }

  Widget _buildFadeBackground(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final backgroundWidth = 531.0;
    final backgroundHeight = 504.0;
    
    return Positioned(
      left: (screenSize.width - backgroundWidth) / 2,
      top: (screenSize.height - backgroundHeight) / 2,
      child: SizedBox(
        width: backgroundWidth,
        height: backgroundHeight,
        child: Stack(
          children: [
            Positioned(
              left: 125,
              top: 0,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 114.6, sigmaY: 114.6),
                child: Container(
                  width: 250,
                  height: 270,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(250, 186, 196, 0.5),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 226,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 114.6, sigmaY: 114.6),
                child: Container(
                  width: 220,
                  height: 230,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(254, 205, 160, 0.5),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 267,
              top: 202,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 114.6, sigmaY: 114.6),
                child: Container(
                  width: 215,
                  height: 230,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(251, 222, 216, 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Girl meets college 💅🌎',
      style: TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontWeight: FontWeight.w500,
        fontSize: 24,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTimer() {
    return const Text(
      'Timer: 11:43 remaining',
      style: TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTeaTopicSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Tea topic of the day:',
            style: TextStyle(
              fontFamily: 'SF Pro Rounded',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Crafty Girls',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.black,
                height: 1.45,
              ),
              children: [
                TextSpan(text: "What's the cringiest thing you've done to get a cute guys attention"),
                TextSpan(
                  text: "😩",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVibeSection() {
    return Container(
      width: double.infinity,
      child: const Padding(
        padding: EdgeInsets.only(left: 40, right: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'The Vibe',
            style: TextStyle(
              fontFamily: 'SF Compact Rounded',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFFABABAB),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '1. One at a time -- wait your turn.\n2. Don\'t hole back girl, drop the tea.\n3. React to everyone -- show your at the table.',
            style: TextStyle(
              fontFamily: 'SF Compact Rounded',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFFABABAB),
              height: 1.2,
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        height: 47,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(37),
        ),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 21),
            child: Text(
              'We know that you have cringing moments too...',
              style: TextStyle(
                fontFamily: 'SF Pro Rounded',
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: Color(0xFF8F8F8F),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStreamElements() {
    return Positioned(
      top: 190,
      right: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // LIVE button with pulse animation
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 252, 252, 0.54),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(83, 83, 83, 0.04),
                      offset: const Offset(1, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        fontFamily: 'SF Compact Rounded',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: 1.65,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      width: 16,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Color.lerp(const Color(0xFFFF6262), const Color(0xFFFF9999), _pulseController.value),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Viewer count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 252, 252, 0.54),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(83, 83, 83, 0.04),
                  offset: const Offset(1, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/ChatGPT Image Aug 27, 2025 at 06_48_31 AM 1.png',
                  width: 21,
                  height: 21,
                ),
                const SizedBox(width: 3),
                Text(
                  '${_viewModel.viewerCount}',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Rounded',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Colors.black,
                    letterSpacing: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Stack(
      children: [
        // Main chat area
        Positioned(
          top: 180,
          left: 40,
          right: 40,
          child: Container(
            height: 324,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFD8D8D8),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60), // Space to move content down under LIVE button
                  // Scrollable confession feed
                  Expanded(
                    child: _viewModel.posts.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Stack(
                            children: [
                              SingleChildScrollView(
                                physics: (!_viewModel.hasPosted && _viewModel.posts.length > 1) 
                                    ? const NeverScrollableScrollPhysics() 
                                    : const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ..._buildPostWidgets(),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                              // Overlay for locked content
                              if (!_viewModel.hasPosted && _viewModel.posts.length > 1)
                                _buildLockedContentOverlay(),
                            ],
                          ),
                  ),
                  // Subtle divider
                  Container(
                    width: double.infinity,
                    height: 1,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDEDBD9),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Queue section
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          '[ Upcoming Turns Queue ]',
                          style: TextStyle(
                            fontFamily: 'SF Pro Rounded',
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            color: Color(0xFFABABAB),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 280,
                          child: const Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              Text(
                                'THATGIRL123',
                                style: TextStyle(
                                  fontFamily: 'SF Compact Rounded',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Color(0xFFFF6262),
                                ),
                              ),
                              Text(
                                '→Who IS ShE',
                                style: TextStyle(
                                  fontFamily: 'SF Compact Rounded',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Color(0xFFABABAB),
                                ),
                              ),
                              Text(
                                '→Girlly',
                                style: TextStyle(
                                  fontFamily: 'SF Compact Rounded',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Color(0xFFABABAB),
                                ),
                              ),
                              Text(
                                '→316 girlly',
                                style: TextStyle(
                                  fontFamily: 'SF Compact Rounded',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Color(0xFFABABAB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Sketch lines - left side
        Positioned(
          top: 160,
          left: 10,
          child: CustomPaint(
            size: const Size(28.29, 20.24),
            painter: SketchLinesPainter1(),
          ),
        ),
        // Timer button - left of comment section
        Positioned(
          top: 190,
          left: 50,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 252, 252, 0.54),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(83, 83, 83, 0.04),
                  offset: const Offset(1, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: _viewModel.shouldShowTimer
              ? Text(
                  '${_viewModel.remainingMinutes.toString().padLeft(2, '0')}:${_viewModel.remainingSeconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontFamily: 'SF Compact Rounded',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Colors.black,
                    letterSpacing: 1.65,
                  ),
                )
              : const SizedBox.shrink(),
          ),
        ),
        // Sketch lines - right side bottom
        Positioned(
          top: 500,
          right: 5,
          child: CustomPaint(
            size: const Size(42, 61.24),
            painter: SketchLinesPainter2(),
          ),
        ),
      ],
    );
  }
}

class SketchLinesPainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    // First line
    canvas.drawLine(
      const Offset(21, 0),
      const Offset(28.29, 15.24),
      paint,
    );
    
    // Second line
    canvas.drawLine(
      const Offset(0, 4),
      const Offset(23.29, 20.24),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SketchLinesPainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    // First line
    canvas.drawLine(
      const Offset(0, 9),
      const Offset(21.29, 61.24),
      paint,
    );
    
    // Second line
    canvas.drawLine(
      const Offset(7, 4),
      const Offset(15, 13),
      paint,
    );
    
    // Third line
    canvas.drawLine(
      const Offset(11, 0),
      const Offset(42, 9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}