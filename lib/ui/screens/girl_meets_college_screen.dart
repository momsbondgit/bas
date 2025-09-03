import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/confession_card.dart';
import '../widgets/status_indicator.dart';
import '../widgets/message_area_typing_indicator.dart';
import '../../view_models/home_view_model.dart';
import '../../services/presence_service.dart';
import '../../config/ritual_config.dart';
import 'session_end_screen.dart';


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
  // Constants
  static const double _containerHorizontalMargin = 17.0;
  static const double _containerBorderRadius = 12.0;
  static const double _contentPadding = 17.0;
  static const double _spaceBelowLiveButton = 60.0;
  static const double _dividerSpacing = 25.0;
  static const double _dividerHeight = 2.0;
  static const double _dividerHorizontalMargin = 20.0;
  static const int _pulseAnimationDuration = 1000;
  static const int _snackBarDuration = 2;

  late HomeViewModel _viewModel;
  late AnimationController _pulseController;
  final PresenceService _presenceService = PresenceService();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _setupPulseAnimation();
    
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initialize();
    
    _presenceService.start();
    _setupTextFieldListeners();
  }

  void _setupTextFieldListeners() {
    _textController.addListener(() {
      if (_textController.text.isNotEmpty) {
        _viewModel.startRealUserTyping();
      } else {
        _viewModel.stopRealUserTyping();
      }
    });
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
      duration: const Duration(milliseconds: _pulseAnimationDuration),
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

  void _handlePostSubmission(String text) async {
    if (text.trim().isEmpty || !_viewModel.canPost) {
      return;
    }
    
    try {
      await _viewModel.submitPost(text);
      
      // Clear the text field
      _textController.clear();
      _focusNode.unfocus();
    } catch (e) {
      // Handle error - could show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to post. Please try again.'),
          duration: Duration(seconds: _snackBarDuration),
        ),
      );
    }
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
    _textController.dispose();
    _focusNode.dispose();
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
    final canPost = _viewModel.canPost;
    print('DEBUG build: canPost=$canPost');
    final activeUser = _viewModel.activeUser;
    
    String placeholderText;
    if (canPost) {
      placeholderText = 'We know that you have cringing moments too...';
    } else if (activeUser != null && activeUser.isReal && !activeUser.isTyping) {
      placeholderText = 'It\'s your turn! Start typing...';
    } else if (activeUser != null) {
      placeholderText = '${activeUser.displayName} ${RitualConfig.typingIndicatorText}';
    } else {
      placeholderText = 'It\'s your turn!';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
            height: 47,
            decoration: BoxDecoration(
              color: canPost ? const Color(0xFFE8E8E8) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(37),
              border: canPost ? null : Border.all(color: const Color(0xFFDDDDDD), width: 1),
            ),
        child: Row(
          children: [
            Expanded(
              child: canPost
                ? TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    enabled: canPost,
                    decoration: InputDecoration(
                      hintText: placeholderText,
                      hintStyle: const TextStyle(
                        fontFamily: 'SF Pro Rounded',
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: Color(0xFF8F8F8F),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(left: 21, right: 12),
                    ),
                    style: const TextStyle(
                      fontFamily: 'SF Pro Rounded',
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    onSubmitted: _handlePostSubmission,
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 21),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        placeholderText,
                        style: const TextStyle(
                          fontFamily: 'SF Pro Rounded',
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Color(0xFFBBBBBB),
                        ),
                      ),
                    ),
                  ),
            ),
            if (canPost)
              GestureDetector(
                onTap: () => _handlePostSubmission(_textController.text),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6262),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'POST',
                    style: TextStyle(
                      fontFamily: 'SF Compact Rounded',
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
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
                  'assets/eye.png',
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
                  // Message content area
                  Flexible(
                    child: _buildMessageAreaContent(),
                  ),
                  // Static divider above Turn Queue
                  _buildStaticDivider(),
                  // Queue section
                  _buildQueueContent(),
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
                  _viewModel.timerDisplay,
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

  Widget _buildMessageAreaContent() {
    final activeUser = _viewModel.activeUser;
    
    // If no active user, show turn message
    if (activeUser == null) {
      return Center(
        child: Text(
          'It\'s your turn!',
          style: const TextStyle(
            fontSize: 16.0,
            color: Color(0xFF8F8F8F),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    // If active user has posted, show only their post with reactions
    if (activeUser.hasPosted) {
      return _buildActiveUserPostView();
    }
    
    // If active user is typing (and not the real user), show typing indicator
    if (activeUser.isTyping && !activeUser.isReal) {
      return MessageAreaTypingIndicator(
        username: activeUser.displayName,
        isVisible: true,
      );
    }
    
    // If someone has their turn but hasn't posted yet, show waiting message
    if (activeUser.isActive) {
      return Center(
        child: Text(
          activeUser.isReal 
            ? (activeUser.isTyping ? 'You are typing…' : 'It\'s your turn!')
            : '${activeUser.displayName} ${RitualConfig.typingIndicatorText}',
          style: const TextStyle(
            fontSize: 16.0,
            color: Color(0xFF8F8F8F),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    // Default: show all posts
    return _buildAllPostsView();
  }

  Widget _buildActiveUserPostView() {
    final activeUser = _viewModel.activeUser;
    if (activeUser == null) return const SizedBox.shrink();
    
    // Get the most recent post (should be the active user's post)
    final posts = _viewModel.posts;
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '${activeUser.displayName} ${activeUser.isReal ? "your" : "their"} post is loading...',
              style: const TextStyle(
                fontSize: 16.0,
                color: Color(0xFF8F8F8F),
              ),
            ),
          ],
        ),
      );
    }
    
    // Show only the most recent post (which should be the active user's)
    final recentPost = posts.first;
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSinglePostWidget(recentPost),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSinglePostWidget(dynamic post) {
    // Extract post data
    final data = post.data() as Map<String, dynamic>;
    final postId = post.id;
    final confession = data['confession'] as String? ?? '';
    final rawReactions = Map<String, dynamic>.from(data['reactions'] ?? {});
    final floor = data['floor'] as int? ?? 1;
    final gender = data['gender'] as String? ?? 'girl';
    
    // Convert reactions to the expected format
    final reactions = <String, int>{};
    rawReactions.forEach((key, value) {
      if (value is List) {
        reactions[key] = value.length;
      } else if (value is int) {
        reactions[key] = value;
      }
    });
    
    return ConfessionCard(
      floor: floor,
      text: confession,
      gender: gender,
      reactions: reactions,
      onReaction: (emoji) => _handleReaction(postId, emoji),
      key: ValueKey(postId),
    );
  }

  Widget _buildAllPostsView() {
    return _viewModel.posts.isEmpty
        ? Center(
            child: Text(
              'It\'s your turn!',
              style: const TextStyle(
                fontSize: 16.0,
                color: Color(0xFF8F8F8F),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          )
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
          );
  }

  Widget _buildStaticDivider() {
    return Column(
      children: [
        const SizedBox(height: 25),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20), // Spacing from comment area borders
          height: 2,
          decoration: const BoxDecoration(
            color: Color(0xFFDEDBD9),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildQueueContent() {
    final activeUser = _viewModel.activeUser;
    final queueState = _viewModel.queueState;
    
    // Use the original fixed queue order (never changes)
    final allUsers = queueState.queue;
    
    return Center(
      child: Column(
        children: [
          // Static header
          const Text(
            '[ Turn Queue ]',
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
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 5,
              runSpacing: 5,
              children: _buildUsersWithSeparators(allUsers, activeUser),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUsersWithSeparators(List users, activeUser) {
    final widgets = <Widget>[];
    
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      final isCurrentUser = user == activeUser;
      
      // Add user name
      widgets.add(
        Text(
          user.displayName,
          style: TextStyle(
            fontFamily: 'SF Compact Rounded',
            fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
            color: isCurrentUser ? const Color(0xFFFF6262) : const Color(0xFFABABAB),
          ),
        ),
      );
      
      // Add separator (except after last user)
      if (i < users.length - 1) {
        widgets.add(
          const Text(
            '|',
            style: TextStyle(
              fontFamily: 'SF Compact Rounded',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Color(0xFFABABAB),
            ),
          ),
        );
      }
    }
    
    return widgets;
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

