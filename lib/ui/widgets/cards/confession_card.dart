import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

class ConfessionCard extends StatelessWidget {
  // Constants
  static const double _tabletBreakpoint = 768.0;
  static const double _desktopBreakpoint = 1024.0;
  static const double _screenWidthFontFactor = 0.038;
  static const double _screenHeightSpacingFactor = 0.008;
  static const double _screenWidthFactor = 0.6;
  static const double _lineHeight = 1.3;
  static const double _blurSigma = 3.0;
  static const double _fontSizeMultiplier = 0.95;  // Slightly smaller to fit numbers
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
  final String gender;
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
    required this.gender,
    this.isBlurred = false,
    this.customAuthor,
    this.isCurrentUser = false,
    this.reactions = const {},
    this.onReaction,
    this.worldId,
  });

  String _generateNickname() {
    final seed = text.hashCode + floor;
    final random = Random(seed);
    return _nicknames[random.nextInt(_nicknames.length)];
  }

  String _getHeaderText() {
    if (isCurrentUser) {
      return 'From: You';
    }
    
    if (customAuthor != null) {
      return 'From: $customAuthor';
    }
    
    return 'From: ${_generateNickname()}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final isTablet = screenWidth >= _tabletBreakpoint;
    final isDesktop = screenWidth >= _desktopBreakpoint;
    
    // Responsive font sizes
    final labelFontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * _screenWidthFontFactor).clamp(14.0, 16.0));
    final textFontSize = isDesktop ? 15.0 : (isTablet ? 14.0 : (screenWidth * _screenWidthFontFactor).clamp(14.0, 16.0));
    final reactionFontSize = isDesktop ? 15.0 : (isTablet ? 14.0 : (screenWidth * _screenWidthFontFactor).clamp(14.0, 16.0));
    
    // Responsive spacing
    final verticalSpacing = (screenHeight * _screenHeightSpacingFactor).clamp(6.0, 12.0);
    
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        // Post header with "from:" prefix
        Text(
          _getHeaderText(),
          style: TextStyle(
            fontFamily: 'SF Compact Rounded',
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        
        SizedBox(height: verticalSpacing),
        
        // Confession text - improved responsive width
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600.0 : (isTablet ? 450.0 : screenWidth * 0.85),
          ),
          child: Text(
            text,
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
        
        SizedBox(height: verticalSpacing),
        
        // Local reactions section (not stored in Firebase)  
        if (onReaction != null)
          _buildReactionRow(reactionFontSize),
          ],
        ),
        
        // Blur overlay when post is restricted
        if (isBlurred)
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
    
    // World-specific reaction labels
    final isGuyWorld = worldId == 'guy-meets-college';
    final reactionLabels = isGuyWorld ? {
      '🤣': 'LMAOO',
      '💀': 'dead',
      '😭': 'not lions gate shorties',
    } : {
      '🤣': 'LMAOO',
      '💀': 'dead',
      '😭': 'not lions gate men',
    };
    
    // Debug logging
    print('[ConfessionCard] Current reactions: $reactions');
    print('[ConfessionCard] Expected emojis: ${reactionLabels.keys.toList()}');
    
    return Row(
      children: [
        // REACT: label (matching original styling)
        Text(
          'REACT: ',
          style: TextStyle(
            fontFamily: 'SF Compact Rounded',
            fontSize: fontSize * _fontSizeMultiplier,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFB2B2B2),
            letterSpacing: 0.4,
          ),
        ),
        // Original reaction format - all on one line
        ...reactionLabels.entries.map((entry) {
            final emoji = entry.key;
            final label = entry.value;
            final count = reactions[emoji] ?? 0;
            final displayText = count > 0 ? '[$label $emoji]$count' : '[$label $emoji]';
            
              return GestureDetector(
                  onTap: () {
                    onReaction?.call(emoji);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: _reactionPadding, vertical: _reactionVerticalPadding),
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontFamily: 'SF Compact Rounded',
                        fontSize: fontSize * _fontSizeMultiplier,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFB2B2B2),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
              );
            }).toList(),
      ],
    );
  }

}