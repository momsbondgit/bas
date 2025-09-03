import 'package:flutter/material.dart';
import 'dart:ui';

class ConfessionCard extends StatelessWidget {
  // Constants
  static const double _tabletBreakpoint = 768.0;
  static const double _desktopBreakpoint = 1024.0;
  static const double _screenWidthFontFactor = 0.038;
  static const double _screenHeightSpacingFactor = 0.008;
  static const double _screenWidthFactor = 0.6;
  static const double _lineHeight = 1.3;
  static const double _blurSigma = 3.0;
  static const double _fontSizeMultiplier = 1.1;
  static const double _reactionSpacing = 8.0;
  static const double _reactionRunSpacing = 4.0;
  static const double _reactionPadding = 6.0;
  static const double _reactionVerticalPadding = 3.0;
  static const double _blurOverlayOpacity = 0.1;
  static const double _messageBoxOpacity = 0.9;
  static const double _messageBoxHorizontalPadding = 20.0;
  static const double _messageBoxVerticalPadding = 15.0;
  static const double _messageBoxBorderRadius = 12.0;
  
  static const List<Map<String, String>> _reactionData = [
    {'label': 'SAMEE', 'emoji': '🤭'},
    {'label': 'DEAD', 'emoji': '☠️'},
    {'label': 'W', 'emoji': '🤪'},
  ];
  
  static const Map<String, String> _reactionLabels = {
    '🤭': 'SAMEE',
    '☠️': 'DEAD', 
    '🤪': 'W',
  };
  final int floor;
  final String text;
  final String gender;
  final Map<String, int> reactions;
  final bool isBlurred;
  final Function(String)? onReaction;
  final String? customAuthor;

  const ConfessionCard({
    super.key,
    required this.floor,
    required this.text,
    required this.gender,
    required this.reactions,
    this.isBlurred = false,
    this.onReaction,
    this.customAuthor,
  });

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
        // Floor and gender label
        Text(
          customAuthor ?? 'A $gender From Freaky Floor $floor',
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
        
        // Reactions
        if (onReaction != null)
          _buildReactionRow(reactionFontSize)
        else
          Text(
            _buildReactionString(),
            style: TextStyle(
              fontFamily: 'SF Compact Rounded',
              fontSize: reactionFontSize,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFB2B2B2),
              letterSpacing: 0.4,
            ),
          ),
        
        SizedBox(height: verticalSpacing),
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
    final reactionData = [
      {'label': 'SAMEE', 'emoji': '🤭'},
      {'label': 'DEAD', 'emoji': '☠️'},
      {'label': 'W', 'emoji': '🤪'},
    ];
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        ...reactionData.map((reaction) {
              final emoji = reaction['emoji']!;
              final label = reaction['label']!;
              final count = reactions[emoji] ?? 0;
              
              return Padding(
                padding: const EdgeInsets.only(right: _reactionSpacing),
                child: GestureDetector(
                  onTap: () => onReaction?.call(emoji),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: _reactionPadding, vertical: _reactionVerticalPadding),
                    child: Text(
                      count > 0 ? '[$label$emoji]$count' : '[$label$emoji]',
                      style: TextStyle(
                        fontFamily: 'SF Compact Rounded',
                        fontSize: fontSize * _fontSizeMultiplier,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFB2B2B2),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ],
    );
  }

  String _buildReactionString() {
    final reactionParts = <String>[];
    final reactionLabels = {
      '🤭': 'SAMEE',
      '☠️': 'DEAD', 
      '🤪': 'W',
    };
    
    reactions.forEach((emoji, count) {
      final label = reactionLabels[emoji] ?? '';
      if (count > 0) {
        reactionParts.add('[$label$emoji]$count');
      } else {
        reactionParts.add('[$label$emoji]');
      }
    });
    
    return 'REACT: ${reactionParts.join(' ')}';
  }

}