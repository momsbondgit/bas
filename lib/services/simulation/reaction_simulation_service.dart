import 'dart:async';
import 'dart:math';

class ReactionSimulationService {
  static final ReactionSimulationService _instance = ReactionSimulationService._internal();
  factory ReactionSimulationService() => _instance;
  ReactionSimulationService._internal();

  final Map<String, List<Timer>> _postTimers = {};
  final Random _random = Random();
  

  // Reaction probabilities based on content sentiment
  static const Map<String, double> _reactionWeights = {
    '😭': 0.34, // LMFAOOO 😭 - funny/relatable content
    '💅': 0.33, // so real 💅 - agreeable/relatable content
    '💀': 0.33, // nah that's wild 💀 - shocking/wild content
  };

  void simulateReactionsForPost({
    required String postId,
    required String content,
    required Function(String emoji) onReaction,
    int? customReactionCount,
    bool isRealUserPost = false,
    bool quickMode = false,
  }) {

    // Stop any existing simulation for this post
    stopSimulationForPost(postId);

    // Calculate realistic reaction count based on 6-user system
    final reactionCount = customReactionCount ?? _calculateReactionCount(isRealUserPost);

    if (reactionCount == 0) {
      return;
    }

    // Pre-select reactions with guaranteed distribution to prevent all reactions going to one type
    final selectedReactions = _generateDistributedReactions(content, reactionCount);
    final timers = <Timer>[];

    for (int i = 0; i < reactionCount; i++) {
      double delaySeconds;

      if (quickMode) {
        // Ultra-fast reactions - 1 second spacing
        delaySeconds = 2.0 + (i * 1.0);
        delaySeconds = delaySeconds.clamp(2.0, 8.0);
      } else {
        // First reaction after 6 seconds, then all others with 1.5-second spacing
        if (i == 0) {
          delaySeconds = 6.0; // First reaction after 6 seconds
        } else {
          delaySeconds = 6.0 + (i * 1.5); // 1.5 seconds between each reaction after first
        }
      }

      final timer = Timer(Duration(milliseconds: (delaySeconds * 1000).round()), () {
        final emoji = selectedReactions[i];
        onReaction(emoji);
      });

      timers.add(timer);
    }

    _postTimers[postId] = timers;
  }

  int _calculateReactionCount(bool isRealUserPost) {
    if (isRealUserPost) {
      // Real user posts get high engagement - heavily weighted toward 6 reactions
      final engagementRoll = _random.nextDouble();

      if (engagementRoll < 0.70) {
        // 70% chance: Full engagement (6 reactions)
        return 6;
      } else if (engagementRoll < 0.95) {
        // 25% chance: High engagement (5 reactions)
        return 5;
      } else {
        // 5% chance: Good engagement (4 reactions)
        return 4;
      }
    } else {
      // Bot posts also get high engagement - weighted toward 6 reactions
      final engagementRoll = _random.nextDouble();

      if (engagementRoll < 0.50) {
        // 50% chance: Full engagement (6 reactions)
        return 6;
      } else if (engagementRoll < 0.80) {
        // 30% chance: High engagement (5 reactions)
        return 5;
      } else if (engagementRoll < 0.95) {
        // 15% chance: Good engagement (4 reactions)
        return 4;
      } else {
        // 5% chance: Moderate engagement (3 reactions)
        return 3;
      }
    }
  }

  List<String> _generateDistributedReactions(String content, int reactionCount) {
    final reactions = <String>[];
    final reactionTypes = ['😭', '💅', '💀'];

    // Ensure each reaction type gets at least one reaction (if count >= 3)
    if (reactionCount >= 3) {
      // Shuffle the reaction types for random order
      final shuffledTypes = List<String>.from(reactionTypes)..shuffle(_random);
      reactions.addAll(shuffledTypes);

      // Fill remaining slots with weighted selection
      for (int i = 3; i < reactionCount; i++) {
        reactions.add(_selectWeightedReaction(content));
      }
    } else {
      // For fewer than 3 reactions, use weighted selection
      for (int i = 0; i < reactionCount; i++) {
        reactions.add(_selectWeightedReaction(content));
      }
    }

    // Shuffle final list to randomize order
    reactions.shuffle(_random);
    return reactions;
  }

  String _selectWeightedReaction(String content) {
    
    // Adjust weights slightly based on content sentiment
    Map<String, double> adjustedWeights = Map.from(_reactionWeights);
    final originalWeights = Map<String, double>.from(adjustedWeights);

    // Simple content analysis for sentiment
    final lowerContent = content.toLowerCase();

    // Boost "so real 💅" for relatable/agreeable content
    if (lowerContent.contains(RegExp(r'\b(same|relatable|me too|this|yes|exactly|facts|so real|real|truth|honestly)\b'))) {
      adjustedWeights['💅'] = adjustedWeights['💅']! * 1.4;
    }

    // Boost "LMFAOOO 😭" for funny content
    if (lowerContent.contains(RegExp(r'\b(dead|dying|lmao|lol|funny|hilarious|omg|wtf|crying|tears)\b'))) {
      adjustedWeights['😭'] = adjustedWeights['😭']! * 1.4;
    }

    // Boost "nah that's wild 💀" for shocking/wild content
    if (lowerContent.contains(RegExp(r'\b(wild|crazy|insane|no way|unbelievable|chaos|wtf|shocked|damn)\b'))) {
      adjustedWeights['💀'] = adjustedWeights['💀']! * 1.5;
    }

    // Weighted random selection
    final totalWeight = adjustedWeights.values.reduce((a, b) => a + b);
    final randomValue = _random.nextDouble() * totalWeight;
    
    double cumulativeWeight = 0.0;
    for (final entry in adjustedWeights.entries) {
      cumulativeWeight += entry.value;
      if (randomValue <= cumulativeWeight) {
        final selectedEmoji = entry.key;
        final originalChance = (originalWeights[selectedEmoji]! / 1.0 * 100).round();
        final adjustedChance = (entry.value / totalWeight * 100).round();
        return selectedEmoji;
      }
    }
    
    // Fallback
    final fallbackEmoji = '😭';
    // Principle: Reliable fallback mechanisms ensure consistent user experience even when primary reaction logic fails
    return fallbackEmoji;
  }

  void stopSimulationForPost(String postId) {
    final timers = _postTimers[postId];
    if (timers != null) {
      for (final timer in timers) {
        timer.cancel();
      }
      _postTimers.remove(postId);
    }
  }

  void stopAllSimulations() {
    final totalTimers = _postTimers.values.fold(0, (sum, timers) => sum + timers.length);
    
    for (final timers in _postTimers.values) {
      for (final timer in timers) {
        timer.cancel();
      }
    }
    _postTimers.clear();
  }

  void dispose() {
    stopAllSimulations();
  }

  // Helper method for testing specific reaction scenarios
  void simulateQuickReactions({
    required String postId,
    required Function(String emoji) onReaction,
    required List<String> reactions,
    double delayBetweenReactions = 4.5, // Slowed down more
  }) {
    stopSimulationForPost(postId);
    
    final timers = <Timer>[];
    
    for (int i = 0; i < reactions.length; i++) {
      final timer = Timer(
        Duration(milliseconds: ((i + 1) * delayBetweenReactions * 1000).round()),
        () => onReaction(reactions[i]),
      );
      timers.add(timer);
    }
    
    _postTimers[postId] = timers;
  }
}