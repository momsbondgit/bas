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
    '🤣': 0.35, // Common - relatable content
    '💀': 0.30, // Common - funny/shocking content  
    '😭': 0.35, // Common - not lions gate reaction
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

    final timers = <Timer>[];

    for (int i = 0; i < reactionCount; i++) {
      double delaySeconds;
      
      if (quickMode) {
        // Ultra-fast reactions for time-sensitive posts - all within 12 seconds (slowed down more)
        delaySeconds = 5.0 + (i * 0.5) + (_random.nextDouble() * 1.0);
        delaySeconds = delaySeconds.clamp(5.0, 12.0);
      } else {
        // Smart timing based on reaction count - more delayed/natural
        // For high reaction counts (10+), use tighter timing to fit all reactions
        final maxTime = reactionCount > 10 ? 25.0 : 22.0; // Slowed down more
        final spacing = maxTime / (reactionCount + 1); // Evenly distribute
        
        final baseDelay = 7.0 + (i * spacing) + (_random.nextDouble() * spacing * 0.5); // Slowed down more
        final jitter = _random.nextDouble() * 1.0 - 0.5; // More jitter
        delaySeconds = (baseDelay + jitter).clamp(7.0, maxTime); // Slowed down more
      }
      
      
      final timer = Timer(Duration(milliseconds: (delaySeconds * 1000).round()), () {
        final emoji = _selectWeightedReaction(content);
        // Principle: Weighted randomness creates authentic user engagement patterns through varied reaction timing and distribution
        onReaction(emoji);
      });

      timers.add(timer);
    }

    _postTimers[postId] = timers;
  }

  int _calculateReactionCount(bool isRealUserPost) {
    if (isRealUserPost) {
      // Real user posts get INSANE engagement - minimum 10 reactions!
      // This means multiple reactions per person, showing they REALLY love the post
      final engagementRoll = _random.nextDouble();
      String engagementLevel;
      int reactionCount;
      
      if (engagementRoll < 0.40) {
        // 40% chance: VIRAL POST! (15-18 reactions)
        reactionCount = 15 + _random.nextInt(4); // 15-18 reactions
        engagementLevel = "VIRAL (absolutely on fire! 🔥)";
      } else if (engagementRoll < 0.70) {
        // 30% chance: EXTREMELY popular (12-14 reactions)
        reactionCount = 12 + _random.nextInt(3); // 12-14 reactions
        engagementLevel = "EXTREMELY POPULAR (everyone's obsessed!)";
      } else if (engagementRoll < 0.90) {
        // 20% chance: Super popular (10-11 reactions)
        reactionCount = 10 + _random.nextInt(2); // 10-11 reactions
        engagementLevel = "SUPER POPULAR (people can't stop reacting!)";
      } else {
        // 10% chance: Still very popular minimum (10 reactions)
        reactionCount = 10;
        engagementLevel = "VERY POPULAR (minimum VIP treatment!)";
      }
      
      return reactionCount;
    } else {
      // Bot posts get good engagement - MINIMUM 5 reactions guaranteed!
      // With 6 users total, we want consistent active engagement
      final engagementRoll = _random.nextDouble();
      String engagementLevel;
      int reactionCount;
      
      if (engagementRoll < 0.30) {
        // 30% chance: Minimum engagement (5 reactions)
        engagementLevel = "minimum active";
        reactionCount = 5;
      } else if (engagementRoll < 0.65) {
        // 35% chance: Good engagement (6-7 reactions) - most common
        engagementLevel = "good";
        reactionCount = 6 + _random.nextInt(2); // 6-7 reactions
      } else if (engagementRoll < 0.90) {
        // 25% chance: High engagement (8-9 reactions)
        engagementLevel = "high";
        reactionCount = 8 + _random.nextInt(2); // 8-9 reactions
      } else {
        // 10% chance: Very high engagement (10+ reactions)
        engagementLevel = "very high";
        reactionCount = 10 + _random.nextInt(3); // 10-12 reactions
      }
      
      return reactionCount;
    }
  }

  String _selectWeightedReaction(String content) {
    
    // Adjust weights slightly based on content sentiment
    Map<String, double> adjustedWeights = Map.from(_reactionWeights);
    final originalWeights = Map<String, double>.from(adjustedWeights);

    // Simple content analysis for sentiment
    final lowerContent = content.toLowerCase();
    
    if (lowerContent.contains(RegExp(r'\b(same|relatable|me too|this|yes|exactly|facts)\b'))) {
      adjustedWeights['🤣'] = adjustedWeights['🤣']! * 1.3;
    }
    
    if (lowerContent.contains(RegExp(r'\b(dead|dying|lmao|lol|funny|hilarious|omg|wtf)\b'))) {
      adjustedWeights['💀'] = adjustedWeights['💀']! * 1.4;
    }
    
    if (lowerContent.contains(RegExp(r'\b(wild|crazy|insane|no way|unbelievable|chaos)\b'))) {
      adjustedWeights['😭'] = adjustedWeights['😭']! * 1.5;
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
    final fallbackEmoji = '🤣';
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