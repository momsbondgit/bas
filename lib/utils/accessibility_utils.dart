import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../models/reaction_type.dart';
import '../config/ritual_config.dart';

class AccessibilityUtils {
  static String getTypingAnnouncementText(String displayName) {
    return '$displayName ${RitualConfig.typingIndicatorText}';
  }

  static String getRotationAnnouncementText(String displayName, bool isActiveUser) {
    if (isActiveUser) {
      return 'It\'s your turn';
    }
    return '$displayName ${RitualConfig.typingIndicatorText}';
  }

  static String getReactionAnnouncementText(ReactionType reaction, int count) {
    final reactionName = reaction.displayName.toLowerCase();
    final countText = count == 1 ? '1 person' : '$count people';
    return '$countText reacted with $reactionName';
  }

  static String getMessageSubmittedAnnouncementText(String displayName) {
    return '$displayName has submitted their message';
  }

  static String getRemainingTimeAnnouncementText(Duration remainingTime) {
    final seconds = remainingTime.inSeconds;
    if (seconds > 60) {
      final minutes = (seconds / 60).floor();
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} remaining';
    }
    return '$seconds ${seconds == 1 ? 'second' : 'seconds'} remaining';
  }

  static void announceToScreenReader(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static void announceLiveRegionUpdate(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static Widget wrapWithSemantics({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? focusable,
    VoidCallback? onTap,
    bool excludeSemantics = false,
    bool liveRegion = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button ?? false,
      focusable: focusable ?? (onTap != null),
      onTap: onTap,
      excludeSemantics: excludeSemantics,
      liveRegion: liveRegion,
      child: child,
    );
  }

  static Widget createAnnouncementWidget({
    required String message,
    required Widget child,
  }) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: child,
    );
  }

  static String getReactionButtonLabel(ReactionType reaction, bool isSelected) {
    final action = isSelected ? 'Remove' : 'Add';
    return '$action ${reaction.displayName.toLowerCase()} reaction';
  }

  static String getQueuePositionLabel(int position, int totalUsers) {
    return 'Position $position of $totalUsers in the queue';
  }

  static Duration getReducedMotionDuration(Duration originalDuration) {
    return Duration(milliseconds: (originalDuration.inMilliseconds * 0.1).round());
  }
}