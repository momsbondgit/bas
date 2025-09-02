import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../models/reaction_type.dart';
import '../../utils/accessibility_utils.dart';

class RitualMessageCard extends StatelessWidget {
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
    
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    final labelFontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * 0.038).clamp(14.0, 16.0));
    final textFontSize = isDesktop ? 15.0 : (isTablet ? 14.0 : (screenWidth * 0.038).clamp(14.0, 16.0));
    final reactionFontSize = isDesktop ? 15.0 : (isTablet ? 14.0 : (screenWidth * 0.038).clamp(14.0, 16.0));
    
    final verticalSpacing = (screenHeight * 0.008).clamp(6.0, 12.0);
    final underlineWidth = isDesktop ? 300.0 : (isTablet ? 250.0 : (screenWidth * 0.6).clamp(180.0, 250.0));

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
          
          Container(
            width: underlineWidth,
            height: 2,
            color: const Color(0xFFDEDBD9),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionRow(double fontSize) {
    final ritualReactions = [
      ReactionType.heart,
      ReactionType.laugh,
      ReactionType.wow,
    ];

    return AccessibilityUtils.wrapWithSemantics(
      label: 'Reaction buttons',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
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
              ...ritualReactions.map((reaction) {
                final count = message.getReactionCount(reaction);
                final isSelected = message.getUserReaction(currentUserId) == reaction;
                
                return AccessibilityUtils.wrapWithSemantics(
                  label: AccessibilityUtils.getReactionButtonLabel(reaction, isSelected),
                  button: true,
                  onTap: () => onReaction?.call(reaction),
                  child: GestureDetector(
                    onTap: () => onReaction?.call(reaction),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                      decoration: isSelected ? BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.0),
                      ) : null,
                      child: Text(
                        count > 0 ? '[${reaction.displayName.toUpperCase()}${reaction.emoji}]$count' : '[${reaction.displayName.toUpperCase()}${reaction.emoji}]',
                        style: TextStyle(
                          fontFamily: 'SF Compact Rounded',
                          fontSize: fontSize * 1.1,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.black : const Color(0xFFB2B2B2),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
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