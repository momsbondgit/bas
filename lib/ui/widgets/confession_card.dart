import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class ConfessionCard extends StatelessWidget {
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
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive font sizes
    final labelFontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * 0.038).clamp(14.0, 16.0));
    final textFontSize = isDesktop ? 15.0 : (isTablet ? 14.0 : (screenWidth * 0.038).clamp(14.0, 16.0));
    final reactionFontSize = isDesktop ? 15.0 : (isTablet ? 14.0 : (screenWidth * 0.038).clamp(14.0, 16.0));
    
    // Responsive spacing
    final verticalSpacing = (screenHeight * 0.008).clamp(6.0, 12.0);
    final underlineWidth = isDesktop ? 300.0 : (isTablet ? 250.0 : (screenWidth * 0.6).clamp(180.0, 250.0));
    
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
        
        // Underline - responsive width
        Container(
          width: underlineWidth,
          height: 2,
          color: const Color(0xFFDEDBD9),
        ),
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
    final emojis = ['😂', '🫢', '🤪'];
    
    return Row(
      children: [
        Text(
          'REACT: ',
          style: TextStyle(
            fontFamily: 'SF Compact Rounded',
            fontSize: fontSize * 1.1,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFB2B2B2),
            letterSpacing: 0.4,
          ),
        ),
        ...emojis.map((emoji) {
          final count = reactions[emoji] ?? 0;
          return GestureDetector(
            onTap: () => onReaction?.call(emoji),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
              margin: const EdgeInsets.only(right: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    emoji,
                    style: TextStyle(fontSize: fontSize * 1.4),
                  ),
                  if (count > 0)
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontFamily: 'SF Compact Rounded',
                        fontSize: fontSize * 1.1,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFB2B2B2),
                        letterSpacing: 0.4,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  String _buildReactionString() {
    final reactionParts = <String>[];
    
    reactions.forEach((emoji, count) {
      if (count > 0) {
        reactionParts.add('$emoji$count');
      } else {
        reactionParts.add(emoji);
      }
    });
    
    return 'REACT: ${reactionParts.join(' ')}';
  }

}