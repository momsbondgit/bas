import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import '../widgets/cards/confession_card.dart';
import '../widgets/indicators/status_indicator.dart';
import '../widgets/indicators/message_area_typing_indicator.dart';
import '../../view_models/home_view_model.dart';
import '../../config/ritual_config.dart';
import '../../config/world_config.dart';
import '../../services/simulation/reaction_simulation_service.dart';
import '../../services/data/local_storage_service.dart';
import '../../services/core/world_service.dart';
import 'session_end_screen.dart';


class GameExperienceScreen extends StatefulWidget {
  final int selectedFloor;
  final WorldConfig? worldConfig;
  
  const GameExperienceScreen({
    super.key,
    required this.selectedFloor,
    this.worldConfig,
  });

  @override
  State<GameExperienceScreen> createState() => _GameExperienceScreenState();
}

class _GameExperienceScreenState extends State<GameExperienceScreen> with TickerProviderStateMixin {
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
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  // Local reaction storage (not persisted to Firebase)
  final Map<String, Map<String, int>> _localReactions = {};
  
  // Reaction simulation
  final ReactionSimulationService _reactionService = ReactionSimulationService();
  final Set<String> _simulatedPosts = {};
  
  // World configuration
  WorldConfig? _currentWorldConfig;

  @override
  void initState() {
    super.initState();
    _loadWorldConfig();
    _viewModel = HomeViewModel();
    _setupPulseAnimation();
    
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initialize();
    
    _setupTextFieldListeners();
  }
  
  void _loadWorldConfig() async {
    if (widget.worldConfig != null) {
      _currentWorldConfig = widget.worldConfig;
    } else {
      // Fall back to loading from local storage
      final localStorageService = LocalStorageService();
      final worldName = await localStorageService.getWorld();
      if (worldName != null) {
        final worldService = WorldService();
        _currentWorldConfig = worldService.getWorldByDisplayName(worldName);
      }
      // Default to Girl Meets College if no world found
      _currentWorldConfig ??= WorldService().getWorldByDisplayName('Girl Meets College');
    }
    if (mounted) setState(() {});
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
    final isExpired = _viewModel.isTimerExpired;
    
    if (isExpired) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const SessionEndScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0), // Start from top (off-screen)
                end: Offset.zero, // End at current position
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
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

  Color _getBackgroundColor() {
    final hue = _currentWorldConfig?.backgroundColorHue ?? 340; // Default pink hue
    // Convert HSL to RGB with 50% saturation, 80% lightness, 0.5 opacity
    final hslColor = HSLColor.fromAHSL(0.5, hue.toDouble(), 0.5, 0.8);
    return hslColor.toColor();
  }

  Color _getSecondaryBackgroundColor() {
    final isGuyWorld = _currentWorldConfig?.id == 'guy-meets-college';
    if (isGuyWorld) {
      // Navy/slate for guy world secondary color (200° hue) - complements deep blue
      final hslColor = HSLColor.fromAHSL(0.5, 200.0, 0.5, 0.8);
      return hslColor.toColor();
    } else {
      // Orange/peach for girl world secondary color
      return const Color.fromRGBO(254, 205, 160, 0.5);
    }
  }

  Color _getTertiaryBackgroundColor() {
    final isGuyWorld = _currentWorldConfig?.id == 'guy-meets-college';
    if (isGuyWorld) {
      // Steel/gray-blue for guy world tertiary color (240° hue) - complements blue family
      final hslColor = HSLColor.fromAHSL(0.5, 240.0, 0.4, 0.8);
      return hslColor.toColor();
    } else {
      // Pink/rose for girl world tertiary color
      return const Color.fromRGBO(251, 222, 216, 0.5);
    }
  }

  // DEBUG: _handleReaction() method was REMOVED during Firebase optimization
  // All reaction handling eliminated - no more Firebase writes for reactions

  void _handlePostSubmission(String text) async {
    if (text.trim().isEmpty || !_viewModel.canPost) {
      return;
    }

    // Check character limit
    if (text.trim().length > 90) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post is too long. Please keep it under 90 characters.'),
          backgroundColor: Colors.red,
        ),
      );
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

  void _handleLocalReaction(String postId, String emoji) {
    print('[GameExperience] _handleLocalReaction called with emoji: $emoji for post: $postId');
    // Add natural delay to simulate reading time before reacting
    // Random delay between 2000-4500ms to feel more human
    final random = Random();
    final delayMs = 2000 + random.nextInt(2500); // 2000-4500ms range
    
    print('[GameExperience] Adding reaction after ${delayMs}ms delay');
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) {
        print('[GameExperience] Actually adding reaction: $emoji to post: $postId');
        setState(() {
          // Initialize reactions for this post if not exists
          _localReactions[postId] ??= {};
          
          // Increment reaction count
          _localReactions[postId]![emoji] = (_localReactions[postId]![emoji] ?? 0) + 1;
          print('[GameExperience] Reaction count for $emoji: ${_localReactions[postId]![emoji]}');
        });
      }
    });
  }

  void _handleUserReaction(String postId, String emoji) {
    // Real user reactions are immediate (no delay)
    if (mounted) {
      setState(() {
        // Initialize reactions for this post if not exists
        _localReactions[postId] ??= {};
        
        // Increment reaction count
        _localReactions[postId]![emoji] = (_localReactions[postId]![emoji] ?? 0) + 1;
      });
    }
  }

  Widget _buildConfessionCard(Map<String, dynamic> data, String postId, {bool isCurrentUser = false}) {
    final content = data['confession'] ?? data['text'] ?? '';
    
    // Start reaction simulation for all new posts (bots will react to everyone including real user)
    if (!_simulatedPosts.contains(postId)) {
      _simulatedPosts.add(postId);
      print('[GameExperience] Starting reaction simulation for post: $postId');
      
      // Start realistic reaction simulation after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          print('[GameExperience] Calling simulateReactionsForPost for: $postId');
          _reactionService.simulateReactionsForPost(
            postId: postId,
            content: content,
            onReaction: (emoji) {
              print('[GameExperience] Bot reaction received: $emoji for post: $postId');
              _handleLocalReaction(postId, emoji);
            },
            isRealUserPost: isCurrentUser,
          );
        } else {
          print('[GameExperience] Not mounted, skipping reactions for: $postId');
        }
      });
    } else {
      print('[GameExperience] Post already simulated: $postId');
    }
    
    return ConfessionCard(
      floor: data['floor'] ?? 0,
      text: content,
      gender: data['gender'] ?? '',
      isBlurred: false,
      customAuthor: data['customAuthor'] as String?,
      isCurrentUser: isCurrentUser,
      reactions: _localReactions[postId] ?? {},
      onReaction: (emoji) => _handleUserReaction(postId, emoji),
      worldId: _currentWorldConfig?.id,
    );
  }

  Widget _buildPaddedPost(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: child,
    );
  }

  List<Widget> _buildPostWidgets() {
    final allPosts = <Widget>[];
    final activeUser = _viewModel.activeUser;
    
    // Add Firebase posts
    for (int i = 0; i < _viewModel.posts.length; i++) {
      final doc = _viewModel.posts[i];
      final data = doc;
      final postId = doc['id'] ?? 'unknown_${i}';
      
      // Check if this is the current user's post (first post from real user who has posted)
      final isCurrentUserPost = activeUser?.isReal == true && 
                               activeUser?.hasPosted == true && 
                               i == 0; // Most recent post is first in the list
      
      allPosts.add(_buildPaddedPost(_buildConfessionCard(data, postId, isCurrentUser: isCurrentUserPost)));
    }
    
    // Add local bot posts (these are never current user posts since they're from bots)
    for (final botPost in _viewModel.localBotPosts) {
      final postId = botPost['id'] as String;
      allPosts.add(_buildPaddedPost(_buildConfessionCard(botPost, postId)));
    }
    
    return allPosts;
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
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _reactionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF9),
      resizeToAvoidBottomInset: false,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, -keyboardHeight, 0),
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: _buildFadeBackground(context),
            ),
            // Top content - fixed position
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    _buildTitle(),
                  ],
                ),
              ),
            ),
            // Topic section - positioned between top and comment section
            Positioned(
              top: screenHeight * 0.12,
              left: 0,
              right: 0,
              child: _buildTeaTopicSection(),
            ),
            // Chat area - fixed position
            Positioned(
              top: screenHeight * 0.28,
              left: 10,
              right: 10,
              height: 324,
              child: _buildChatContent(),
            ),
            // LIVE button - fixed position
            Positioned(
              top: screenHeight * 0.28 + 10,
              right: 25,
              child: _buildLiveButton(),
            ),
            // Timer button - fixed position
            Positioned(
              top: screenHeight * 0.28 + 10,
              left: 25,
              child: _buildTimerButton(),
            ),
            // Fixed bottom input
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: _buildBottomInput(),
            ),
          ],
        ),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getBackgroundColor(),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getSecondaryBackgroundColor(),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getTertiaryBackgroundColor(),
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
    final worldName = _currentWorldConfig?.displayName ?? 'Girl Meets College';
    final emoji = _currentWorldConfig?.id == 'guy-meets-college' ? '🏀🌎' : '💅🌎';
    
    return Text(
      '${worldName.toLowerCase()} $emoji',
      style: const TextStyle(
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
    final rawTopicText = _currentWorldConfig?.topicOfDay ?? "What's the cringiest thing you've done to get a cute guys attention😩";
    
    // Ensure last word and emoji stay together by replacing last space with non-breaking space
    final topicText = _fixLastWordEmojiWrapping(rawTopicText);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            '${_currentWorldConfig?.headingText ?? 'Tea topic of the day'}:',
            style: const TextStyle(
              fontFamily: 'SF Pro Rounded',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            topicText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Crafty Girls',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.black,
              height: 1.45,
            ),
            softWrap: true,
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  String _fixLastWordEmojiWrapping(String text) {
    // Find the last space before emoji(s) and replace with non-breaking space
    // Simple approach: replace last space before any emoji with non-breaking space
    final emojiPattern = RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}]+$', unicode: true);
    final match = emojiPattern.firstMatch(text);
    
    if (match != null) {
      final emojiStart = match.start;
      final beforeEmoji = text.substring(0, emojiStart).trimRight();
      final emoji = text.substring(emojiStart);
      
      // Replace the last space with non-breaking space
      final lastSpaceIndex = beforeEmoji.lastIndexOf(' ');
      if (lastSpaceIndex != -1) {
        final beforeLastWord = beforeEmoji.substring(0, lastSpaceIndex);
        final lastWord = beforeEmoji.substring(lastSpaceIndex + 1);
        return '$beforeLastWord\u00A0$lastWord$emoji'; // \u00A0 is non-breaking space
      }
    }
    
    return text;
  }


  Widget _buildBottomInput() {
    final canPost = _viewModel.canPost;
    final activeUser = _viewModel.activeUser;
    
    String placeholderText;
    if (canPost) {
      final isGuyWorld = _currentWorldConfig?.id == 'guy-meets-college';
      placeholderText = isGuyWorld 
        ? 'We know you\'ve had some dumb moments too...'
        : 'We know that you have cringing moments too...';
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
        constraints: const BoxConstraints(
          minHeight: 47,
          maxHeight: 47, // Fixed height to match waiting state
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(37),
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: canPost
                ? TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: canPost,
                      cursorColor: const Color(0xFF8F8F8F),
                      maxLength: 90, // Character limit for two full lines
                      buildCounter: (context, {required int currentLength, required bool isFocused, int? maxLength}) {
                        // Hide counter to match waiting state size
                        return const SizedBox.shrink();
                      },
                      decoration: InputDecoration(
                        hintText: placeholderText,
                        hintStyle: const TextStyle(
                          fontFamily: 'SF Pro Rounded',
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Color(0xFF8F8F8F),
                        ),
                        hintTextDirection: TextDirection.ltr,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(left: 21, right: 50, top: 8, bottom: 8),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'SF Pro Rounded',
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: Colors.black,
                        height: 1.2,
                      ),
                      maxLines: null,
                      minLines: 1,
                      textAlign: TextAlign.left,
                      expands: false,
                      scrollController: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      textAlignVertical: TextAlignVertical.top,
                      onSubmitted: null,
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
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => _handlePostSubmission(_textController.text),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6262),
                        borderRadius: BorderRadius.circular(14),
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
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveButton() {
    return Row(
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
                  'Assets/eye.png',
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
      );
  }

  Widget _buildTimerButton() {
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
    );
  }

  Widget _buildChatContent() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFD8D8D8),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
    
    Widget? activeUserPostWidget;
    
    if (activeUser.isReal) {
      // For real user, find their post in Firebase posts (most recent)
      final posts = _viewModel.posts;
      if (posts.isNotEmpty) {
        final recentPost = posts.first;
        final data = recentPost;
        final postId = recentPost['id'] ?? 'unknown';
        activeUserPostWidget = _buildConfessionCard(data, postId, isCurrentUser: true);
      }
    } else {
      // For bot user, find their post in local bot posts
      final botPosts = _viewModel.localBotPosts;
      for (final botPost in botPosts) {
        final postAuthor = botPost['customAuthor'] as String?;
        if (postAuthor == activeUser.displayName) {
          final postId = botPost['id'] as String;
          activeUserPostWidget = _buildConfessionCard(botPost, postId);
          break;
        }
      }
    }
    
    // If no post found, show loading
    if (activeUserPostWidget == null) {
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
    
    // Show only the active user's specific post
    return SingleChildScrollView(
      child: Column(
        children: [_buildPaddedPost(activeUserPostWidget)],
      ),
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
            fontSize: 14,
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
              fontSize: 14,
              color: Color(0xFFABABAB),
            ),
          ),
        );
      }
    }
    
    return widgets;
  }
}


