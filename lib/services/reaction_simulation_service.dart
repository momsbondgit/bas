import 'dart:async';
import 'dart:math';

class ReactionSimulationService {
  static final ReactionSimulationService _instance = ReactionSimulationService._internal();
  factory ReactionSimulationService() => _instance;
  ReactionSimulationService._internal();

  final Map<String, Timer> _activeTimers = {};
  final Map<String, List<Timer>> _postTimers = {};
  final Random _random = Random();
  
  // System has 6 total users (1 real + 5 bots), so reactions should reflect active engagement
  static const int _totalSystemUsers = 6;

  // Confession-style reactions matching the existing system
  static const Map<String, String> _reactionEmojis = {
    '🤭': 'SAMEE',
    '☠️': 'DEAD', 
    '🤪': 'W',
  };

  // Reaction probabilities based on content sentiment
  static const Map<String, double> _reactionWeights = {
    '🤭': 0.45, // Most common - relatable content
    '☠️': 0.35, // Second most common - funny/shocking content  
    '🤪': 0.20, // Least common - wild content
  };

  void simulateReactionsForPost({
    required String postId,
    required String content,
    required Function(String emoji) onReaction,
    int? customReactionCount,
    bool isRealUserPost = false,
    bool quickMode = false,
  }) {
    print('🎭 REACTION_SIM: Starting simulation for post $postId');
    
    // Stop any existing simulation for this post
    stopSimulationForPost(postId);

    // Calculate realistic reaction count based on 6-user system
    final reactionCount = customReactionCount ?? _calculateReactionCount(isRealUserPost);
    
    final userType = isRealUserPost ? "REAL USER" : "bot";
    print('🎭 REACTION_SIM: Post $postId ($userType) will receive $reactionCount reactions (${_totalSystemUsers} users in system)');
    
    if (reactionCount == 0) {
      print('🎭 REACTION_SIM: Post $postId gets no reactions (natural variation)');
      return;
    }

    final timers = <Timer>[];

    for (int i = 0; i < reactionCount; i++) {
      double delaySeconds;
      String timingMode;
      
      if (quickMode) {
        // Ultra-fast reactions for time-sensitive posts - all within 3 seconds
        delaySeconds = 0.5 + (i * 0.15) + (_random.nextDouble() * 0.2);
        delaySeconds = delaySeconds.clamp(0.5, 3.0);
        timingMode = "ULTRA-FAST";
      } else {
        // Smart timing based on reaction count
        // For high reaction counts (10+), use tighter timing to fit all reactions
        final maxTime = reactionCount > 10 ? 8.0 : 8.0;
        final spacing = maxTime / (reactionCount + 1); // Evenly distribute
        
        final baseDelay = 0.5 + (i * spacing) + (_random.nextDouble() * spacing * 0.3);
        final jitter = _random.nextDouble() * 0.2 - 0.1;
        delaySeconds = (baseDelay + jitter).clamp(0.5, maxTime);
        timingMode = reactionCount > 10 ? "HIGH-VOLUME-FAST" : "FAST";
      }
      
      print('🎭 REACTION_SIM: Reaction ${i + 1} for post $postId scheduled in ${delaySeconds.toStringAsFixed(1)}s ($timingMode timing)');
      
      final timer = Timer(Duration(milliseconds: (delaySeconds * 1000).round()), () {
        final emoji = _selectWeightedReaction(content);
        print('🎭 REACTION_SIM: Triggering reaction $emoji for post $postId (${i + 1}/$reactionCount)');
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
      
      print('🎭 REACTION_SIM: REAL USER engagement level: $engagementLevel ($reactionCount reactions)');
      return reactionCount;
    } else {
      // Bot posts get normal engagement distribution
      // With 6 users total, we want good engagement but natural variation
      final engagementRoll = _random.nextDouble();
      String engagementLevel;
      int reactionCount;
      
      if (engagementRoll < 0.05) {
        // 5% chance: No reactions (post didn't resonate)
        engagementLevel = "none";
        reactionCount = 0;
      } else if (engagementRoll < 0.20) {
        // 15% chance: Low engagement (1-2 reactions)
        engagementLevel = "low";
        reactionCount = 1 + _random.nextInt(2); // 1-2 reactions
      } else if (engagementRoll < 0.75) {
        // 55% chance: Good engagement (3-4 reactions) - most common
        engagementLevel = "good";
        reactionCount = 3 + _random.nextInt(2); // 3-4 reactions
      } else if (engagementRoll < 0.95) {
        // 20% chance: High engagement (5 reactions)
        engagementLevel = "high";
        reactionCount = 5;
      } else {
        // 5% chance: Very high engagement (6 reactions)
        engagementLevel = "very high";
        reactionCount = 6;
      }
      
      print('🎭 REACTION_SIM: Bot engagement level: $engagementLevel ($reactionCount reactions)');
      return reactionCount;
    }
  }

  String _selectWeightedReaction(String content) {
    print('🎭 REACTION_SIM: Analyzing sentiment for content: "${content.length > 50 ? content.substring(0, 50) + '...' : content}"');
    
    // Adjust weights slightly based on content sentiment
    Map<String, double> adjustedWeights = Map.from(_reactionWeights);
    final originalWeights = Map<String, double>.from(adjustedWeights);

    // Simple content analysis for sentiment
    final lowerContent = content.toLowerCase();
    
    if (lowerContent.contains(RegExp(r'\b(same|relatable|me too|this|yes|exactly|facts)\b'))) {
      adjustedWeights['🤭'] = adjustedWeights['🤭']! * 1.3;
      print('🎭 REACTION_SIM: Detected relatable content - boosted 🤭 SAMEE reactions');
    }
    
    if (lowerContent.contains(RegExp(r'\b(dead|dying|lmao|lol|funny|hilarious|omg|wtf)\b'))) {
      adjustedWeights['☠️'] = adjustedWeights['☠️']! * 1.4;
      print('🎭 REACTION_SIM: Detected funny content - boosted ☠️ DEAD reactions');
    }
    
    if (lowerContent.contains(RegExp(r'\b(wild|crazy|insane|no way|unbelievable|chaos)\b'))) {
      adjustedWeights['🤪'] = adjustedWeights['🤪']! * 1.5;
      print('🎭 REACTION_SIM: Detected wild content - boosted 🤪 W reactions');
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
        print('🎭 REACTION_SIM: Selected $selectedEmoji (${originalChance}% → ${adjustedChance}% chance)');
        return selectedEmoji;
      }
    }
    
    // Fallback
    print('🎭 REACTION_SIM: Using fallback reaction 🤭');
    return '🤭';
  }

  void stopSimulationForPost(String postId) {
    final timers = _postTimers[postId];
    if (timers != null) {
      print('🎭 REACTION_SIM: Stopping simulation for post $postId (${timers.length} pending reactions)');
      for (final timer in timers) {
        timer.cancel();
      }
      _postTimers.remove(postId);
    }
  }

  void stopAllSimulations() {
    final totalTimers = _postTimers.values.fold(0, (sum, timers) => sum + timers.length);
    print('🎭 REACTION_SIM: Stopping all simulations (${_postTimers.length} posts, $totalTimers pending reactions)');
    
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
    double delayBetweenReactions = 1.0,
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