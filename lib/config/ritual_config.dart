class RitualConfig {
  static const Duration defaultTurnDuration = Duration(seconds: 60);
  static const Duration bannerDisplayDuration = Duration(seconds: 4);
  static const Duration typingDebounceDelay = Duration(milliseconds: 500);
  
  static const int targetFPS = 60;
  static const Duration dotBounceDuration = Duration(milliseconds: 600);
  static const Duration shimmerDuration = Duration(seconds: 2);
  
  static const double dotSize = 4.0;
  static const double dotSpacing = 8.0;
  static const int numberOfDots = 3;
  
  static const Duration bannerAnimationDuration = Duration(milliseconds: 300);
  static const Duration messageCardAnimationDuration = Duration(milliseconds: 200);
  
  static const double bannerHeight = 60.0;
  static const double bannerBorderRadius = 12.0;
  
  static const double reactionButtonSize = 32.0;
  static const double reactionEmojiSize = 18.0;
  
  static const String typingIndicatorText = 'is typing…';
  static const String newTurnBannerPrefix = 'New turn: ';
  static const String yourTurnBannerText = "It's your turn";
  
  static const Map<String, int> animationStaggerOffsets = {
    'dot0': 0,
    'dot1': 100,
    'dot2': 200,
  };
}