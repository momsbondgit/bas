import 'package:flutter/material.dart';
import '../../models/ritual_queue_state.dart';
import '../../models/reaction_type.dart';
import '../../utils/accessibility_utils.dart';
import 'typing_animation_widget.dart';
import 'ritual_message_card.dart';
import 'queue_rotation_banner.dart';

class ActiveUserFeedWidget extends StatelessWidget {
  const ActiveUserFeedWidget({
    super.key,
    required this.queueState,
    required this.currentUserId,
    required this.onReaction,
    required this.onDismissBanner,
  });

  final RitualQueueState queueState;
  final String currentUserId;
  final Function(String messageId, ReactionType reaction)? onReaction;
  final VoidCallback onDismissBanner;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (queueState.showRotationBanner)
          QueueRotationBanner(
            displayName: queueState.rotationTargetDisplayName ?? queueState.activeDisplayName,
            isActiveUser: queueState.rotationTargetDisplayName == null
                ? queueState.activeUserId == currentUserId
                : false, // Will be updated when rotation completes
            onDismiss: onDismissBanner,
          ),
        
        Expanded(
          child: _buildFeedContent(context),
        ),
      ],
    );
  }

  Widget _buildFeedContent(BuildContext context) {
    if (queueState.userQueue.isEmpty) {
      return _buildEmptyState(context);
    }

    switch (queueState.phase) {
      case QueuePhase.waiting:
        return _buildWaitingState(context);
      
      case QueuePhase.typing:
        return _buildTypingState(context);
      
      case QueuePhase.submitted:
        return _buildSubmittedState(context);
      
      case QueuePhase.rotating:
        return _buildRotatingState(context);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    final fontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * 0.038).clamp(14.0, 16.0));

    return Center(
      child: AccessibilityUtils.wrapWithSemantics(
        label: 'Ritual queue is empty, waiting for participants',
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Ritual queue is empty.\nWaiting for participants to join...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Compact Rounded',
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFB2B2B2),
              letterSpacing: 0.4,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    final fontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * 0.038).clamp(14.0, 16.0));

    final isActiveUser = queueState.activeUserId == currentUserId;
    final message = isActiveUser 
        ? 'It\'s your turn! Start typing to begin...'
        : 'Waiting for ${queueState.activeDisplayName} to start typing...';

    return Center(
      child: AccessibilityUtils.wrapWithSemantics(
        label: message,
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Compact Rounded',
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: isActiveUser ? Colors.green.shade700 : const Color(0xFFB2B2B2),
              letterSpacing: 0.4,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingState(BuildContext context) {
    return Center(
      child: TypingAnimationWidget(
        displayName: queueState.activeDisplayName,
      ),
    );
  }

  Widget _buildSubmittedState(BuildContext context) {
    if (queueState.currentMessage == null) {
      return _buildWaitingState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: RitualMessageCard(
        message: queueState.currentMessage!,
        currentUserId: currentUserId,
        onReaction: queueState.reactionsEnabled && onReaction != null
            ? (reaction) => onReaction!(queueState.currentMessage!.id, reaction)
            : null,
        reactionsEnabled: queueState.reactionsEnabled,
      ),
    );
  }

  Widget _buildRotatingState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    final fontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * 0.038).clamp(14.0, 16.0));

    return Center(
      child: AccessibilityUtils.wrapWithSemantics(
        label: 'Queue is rotating to the next person',
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB2B2B2)),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Rotating queue...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SF Compact Rounded',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFB2B2B2),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}