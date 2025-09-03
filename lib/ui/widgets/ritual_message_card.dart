import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../models/reaction_type.dart';
import '../../utils/accessibility_utils.dart';

class RitualMessageCard extends StatelessWidget {
  // Constants
  static const double _tabletBreakpoint = 768.0;
  static const double _desktopBreakpoint = 1024.0;
  static const double _screenWidthFontFactor = 0.038;
  static const double _screenHeightSpacingFactor = 0.008;
  static const double _lineHeight = 1.3;
  static const double _fontSizeMultiplier = 1.1;
  static const double _reactionSpacing = 8.0;
  static const double _reactionRunSpacing = 4.0;
  static const double _reactionPadding = 6.0;
  static const double _reactionVerticalPadding = 3.0;
  
  static const List<ReactionType> _ritualReactions = [
    ReactionType.heart,
    ReactionType.laugh,
    ReactionType.wow,
  ];
  const RitualMessageCard({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.onReaction,
    this.reactionsEnabled = true,
  });

  final Message message;
  final String currentUserId;
  final Function(ReactionType)? onReaction;
  final bool reactionsEnabled;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final isTablet = screenWidth >= _tabletBreakpoint;
    final isDesktop = screenWidth >= _desktopBreakpoint;
    
    final labelFontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * _screenWidthFontFactor).clamp(14.0, 16.0));
    final textFontSize = isDesktop ? 15.0 : (isTablet ? 14.0 : (screenWidth * _screenWidthFontFactor).clamp(14.0, 16.0));
    final reactionFontSize = isDesktop ? 15.0 : (isTablet ? 14.0 : (screenWidth * _screenWidthFontFactor).clamp(14.0, 16.0));
    
    final verticalSpacing = (screenHeight * _screenHeightSpacingFactor).clamp(6.0, 12.0);

    return AccessibilityUtils.wrapWithSemantics(
      label: 'Message from ${message.displayName}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.displayName,
            style: TextStyle(
              fontFamily: 'SF Compact Rounded',
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          
          SizedBox(height: verticalSpacing),
          
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 600.0 : (isTablet ? 450.0 : screenWidth * 0.85),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                fontFamily: 'SF Compact Rounded',
                fontSize: textFontSize,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                letterSpacing: 0.4,
                height: 1.3,
              ),
              softWrap: true,
            ),
          ),
          
          SizedBox(height: verticalSpacing),
          
          if (onReaction != null && reactionsEnabled)
            _buildReactionRow(reactionFontSize)
          else if (message.reactions.isNotEmpty)
            _buildReactionDisplay(reactionFontSize),
          
          SizedBox(height: verticalSpacing),
        ],
      ),
    );
  }

  Widget _buildReactionRow(double fontSize) {
    return AccessibilityUtils.wrapWithSemantics(
      label: 'Reaction buttons',
      child: Row(
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
          ..._ritualReactions.map((reaction) {
                final count = message.getReactionCount(reaction);
                final isSelected = message.getUserReaction(currentUserId) == reaction;
                
                return Padding(
                  padding: const EdgeInsets.only(right: _reactionSpacing),
                  child: AccessibilityUtils.wrapWithSemantics(
                    label: AccessibilityUtils.getReactionButtonLabel(reaction, isSelected),
                    button: true,
                    onTap: () => onReaction?.call(reaction),
                    child: GestureDetector(
                      onTap: () => onReaction?.call(reaction),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: _reactionPadding, vertical: _reactionVerticalPadding),
                        decoration: isSelected ? BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.0),
                        ) : null,
                        child: Text(
                          count > 0 ? '[${reaction.displayName.toUpperCase()}${reaction.emoji}]$count' : '[${reaction.displayName.toUpperCase()}${reaction.emoji}]',
                          style: TextStyle(
                            fontFamily: 'SF Compact Rounded',
                            fontSize: fontSize * _fontSizeMultiplier,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.black : const Color(0xFFB2B2B2),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ],
      ),
    );
  }

  Widget _buildReactionDisplay(double fontSize) {
    final reactionParts = <String>[];
    
    for (final reaction in ReactionType.values) {
      final count = message.getReactionCount(reaction);
      if (count > 0) {
        reactionParts.add('[${reaction.displayName.toUpperCase()}${reaction.emoji}]$count');
      }
    }

    if (reactionParts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      'REACT: ${reactionParts.join(' ')}',
      style: TextStyle(
        fontFamily: 'SF Compact Rounded',
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFB2B2B2),
        letterSpacing: 0.4,
      ),
    );
  }
}