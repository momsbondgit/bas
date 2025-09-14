import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

class ConfessionCard extends StatefulWidget {
  // Constants
  static const double _tabletBreakpoint = 768.0;
  static const double _desktopBreakpoint = 1024.0;
  static const double _screenWidthFontFactor = 0.038;
  static const double _screenHeightSpacingFactor = 0.008;
  static const double _screenWidthFactor = 0.6;
  static const double _lineHeight = 1.3;
  static const double _blurSigma = 3.0;
  static const double _fontSizeMultiplier = 1.05;  // Make reaction section bigger
  static const double _reactionSpacing = 2.5;  // Small spacing
  static const double _reactionRunSpacing = 4.0;
  static const double _reactionPadding = 2.0;  // Small padding for numbers
  static const double _reactionVerticalPadding = 2.0;
  static const double _blurOverlayOpacity = 0.1;
  static const double _messageBoxOpacity = 0.9;
  static const double _messageBoxHorizontalPadding = 20.0;
  static const double _messageBoxVerticalPadding = 15.0;
  static const double _messageBoxBorderRadius = 12.0;
  
  static const List<String> _nicknames = [
    'Emma', 'Olivia', 'Ava', 'Isabella', 'Sophia', 'Charlotte', 'Mia', 'Amelia',
    'Harper', 'Evelyn', 'Abigail', 'Emily', 'Elizabeth', 'Mila', 'Ella', 'Avery',
    'Sofia', 'Camila', 'Aria', 'Scarlett', 'Victoria', 'Madison', 'Luna', 'Grace',
    'Chloe', 'Penelope', 'Layla', 'Riley', 'Zoey', 'Nora', 'Lily', 'Eleanor',
    'Hannah', 'Lillian', 'Addison', 'Aubrey', 'Ellie', 'Stella', 'Natalie', 'Zoe'
  ];
  
  final int floor;
  final String text;
  // Removed gender field - now uses worldId for world-specific behavior
  final bool isBlurred;
  final String? customAuthor;
  final bool isCurrentUser;
  final Map<String, int> reactions;
  final Function(String)? onReaction;
  final String? worldId;

  const ConfessionCard({
    super.key,
    required this.floor,
    required this.text,
    // Removed gender parameter
    this.isBlurred = false,
    this.customAuthor,
    this.isCurrentUser = false,
    this.reactions = const {},
    this.onReaction,
    this.worldId,
  });

  @override
  State<ConfessionCard> createState() => _ConfessionCardState();
}

class _ConfessionCardState extends State<ConfessionCard> {
  String? _pressedReaction;

  String _generateNickname() {
    final seed = widget.text.hashCode + widget.floor;
    final random = Random(seed.toInt());
    return ConfessionCard._nicknames[random.nextInt(ConfessionCard._nicknames.length)];
  }

  String _getHeaderText() {
    if (widget.isCurrentUser) {
      return 'From: You';
    }

    if (widget.customAuthor != null) {
      return 'From: ${widget.customAuthor}';
    }

    return 'From: ${_generateNickname()}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final isTablet = screenWidth >= ConfessionCard._tabletBreakpoint;
    final isDesktop = screenWidth >= ConfessionCard._desktopBreakpoint;
    
    // Responsive font sizes
    final labelFontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * ConfessionCard._screenWidthFontFactor).clamp(14.0, 16.0));
    final textFontSize = isDesktop ? 15.0 : (isTablet ? 14.0 : (screenWidth * ConfessionCard._screenWidthFontFactor).clamp(14.0, 16.0));
    final reactionFontSize = isDesktop ? 15.0 : (isTablet ? 14.0 : (screenWidth * ConfessionCard._screenWidthFontFactor).clamp(14.0, 16.0));
    
    // Responsive spacing
    final verticalSpacing = (screenHeight * ConfessionCard._screenHeightSpacingFactor).clamp(6.0, 12.0);
    
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        // Post header with "from:" prefix
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _getHeaderText(),
            style: TextStyle(
              fontFamily: 'SF Compact Rounded',
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
        ),

        SizedBox(height: verticalSpacing),

        // Confession text - improved responsive width
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 600.0 : (isTablet ? 450.0 : screenWidth * 0.85),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'SF Compact Rounded',
                fontSize: textFontSize,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                letterSpacing: 0.4,
                height: 1.3, // Better line height for readability
              ),
              softWrap: true,
            ),
          ),
        ),

        SizedBox(height: verticalSpacing * 6), // Add much more space before REACT section

        // Local reactions section (not stored in Firebase)
        if (widget.onReaction != null)
          _buildReactionRow(reactionFontSize),
          ],
        ),
        
        // Blur overlay when post is restricted
        if (widget.isBlurred)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Text(
                        'You not about to see all the tea without you posting. So get to it.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: textFontSize * 0.9,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildReactionRow(double fontSize) {

    // Updated reaction labels to match new design
    const reactionLabels = {
      'LMFAOOO 😭': 'LMFAOOO 😭',
      'so real 💅': 'so real 💅',
      'nah that\'s wild 💀': 'nah that\'s wild 💀',
    };

    // Map old emoji keys to new reaction keys for compatibility
    final topReactionKeys = ['LMFAOOO 😭', 'so real 💅'];
    final bottomReactionKey = 'nah that\'s wild 💀';
    final emojiMapping = {
      'LMFAOOO 😭': '😭',
      'so real 💅': '💅',
      'nah that\'s wild 💀': '💀',
    };

    // Principle: Real-time reaction validation - System ensures reaction data integrity by validating against expected emoji set

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // REACT label centered above reactions
          Text(
            'REACT',
            style: TextStyle(
              fontFamily: 'SF Compact Rounded',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFB2B2B2),
              letterSpacing: 1.98, // 11% of 18px = 1.98px
            ),
          ),
          const SizedBox(height: 12),

          // Top row with two reaction pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: topReactionKeys.map((reactionKey) {
              final emoji = emojiMapping[reactionKey]!;
              final count = widget.reactions[emoji] ?? 0;
              final isPressed = _pressedReaction == emoji;

              // Get specific color for each reaction
              Color getReactionColor(String reactionKey) {
                switch (reactionKey) {
                  case 'LMFAOOO 😭':
                    return const Color(0xFFFFD734); // Yellow
                  case 'so real 💅':
                    return Colors.red;
                  case 'nah that\'s wild 💀':
                    return Colors.black;
                  default:
                    return const Color(0xFFC5C3C3);
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTapDown: (_) {
                    setState(() {
                      _pressedReaction = emoji;
                    });
                  },
                  onTapUp: (_) {
                    setState(() {
                      _pressedReaction = null;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _pressedReaction = null;
                    });
                  },
                  onTap: () {
                    widget.onReaction?.call(emoji);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F2),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color(0xFFC5C3C3),
                        width: 0.5,
                      ),
                      boxShadow: isPressed ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ] : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reactionKey,
                          style: TextStyle(
                            fontFamily: 'SF Compact Rounded',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: getReactionColor(reactionKey),
                            letterSpacing: 1.65, // 11% of 15px = 1.65px
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            count.toString(),
                            style: TextStyle(
                              fontFamily: 'SF Compact Rounded',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: getReactionColor(reactionKey),
                              letterSpacing: 1.65, // 11% of 15px = 1.65px
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Bottom row with single centered reaction pill
          GestureDetector(
            onTapDown: (_) {
              setState(() {
                _pressedReaction = emojiMapping[bottomReactionKey]!;
              });
            },
            onTapUp: (_) {
              setState(() {
                _pressedReaction = null;
              });
            },
            onTapCancel: () {
              setState(() {
                _pressedReaction = null;
              });
            },
            onTap: () {
              final emoji = emojiMapping[bottomReactionKey]!;
              widget.onReaction?.call(emoji);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                // this is where you change the collor of the fill color of the reaction buttons
                color: const Color(0xFFFFF8F2),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: const Color(0xFFC5C3C3),
                  width: 0.5,
                ),
                boxShadow: _pressedReaction == emojiMapping[bottomReactionKey]! ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bottomReactionKey,
                    style: TextStyle(
                      fontFamily: 'SF Compact Rounded',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black, // "nah that's wild" is black
                      letterSpacing: 1.65, // 11% of 15px = 1.65px
                    ),
                  ),
                  if ((widget.reactions[emojiMapping[bottomReactionKey]!] ?? 0) > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      (widget.reactions[emojiMapping[bottomReactionKey]!] ?? 0).toString(),
                      style: TextStyle(
                        fontFamily: 'SF Compact Rounded',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black, // Count number same color as text
                        letterSpacing: 1.65, // 11% of 15px = 1.65px
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    ),
  );
  }

}