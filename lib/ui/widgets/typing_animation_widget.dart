import 'package:flutter/material.dart';
import '../../config/ritual_config.dart';
import '../../utils/animation_utils.dart';
import '../../utils/accessibility_utils.dart';

class TypingAnimationWidget extends StatefulWidget {
  const TypingAnimationWidget({
    super.key,
    required this.displayName,
  });

  final String displayName;

  @override
  State<TypingAnimationWidget> createState() => _TypingAnimationWidgetState();
}

class _TypingAnimationWidgetState extends State<TypingAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _shimmerController;
  
  late Animation<double> _dot1Animation;
  late Animation<double> _dot2Animation;
  late Animation<double> _dot3Animation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _bounceController = AnimationController(
      duration: AnimationUtils.getAnimationDuration(
        context,
        RitualConfig.dotBounceDuration,
      ),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: AnimationUtils.getAnimationDuration(
        context,
        RitualConfig.shimmerDuration,
      ),
      vsync: this,
    );

    _dot1Animation = AnimationUtils.createBounceAnimation(_bounceController, 0);
    _dot2Animation = AnimationUtils.createBounceAnimation(_bounceController, 1);
    _dot3Animation = AnimationUtils.createBounceAnimation(_bounceController, 2);
    _shimmerAnimation = AnimationUtils.createShimmerAnimation(_shimmerController);
  }

  void _startAnimations() {
    if (!AnimationUtils.shouldReduceMotion(context)) {
      _bounceController.repeat();
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    final fontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * 0.038).clamp(14.0, 16.0));

    return AccessibilityUtils.wrapWithSemantics(
      label: AccessibilityUtils.getTypingAnnouncementText(widget.displayName),
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.displayName} ',
              style: TextStyle(
                fontFamily: 'SF Compact Rounded',
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
            AnimationUtils.shouldReduceMotion(context)
                ? Text(
                    RitualConfig.typingIndicatorText,
                    style: TextStyle(
                      fontFamily: 'SF Compact Rounded',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFB2B2B2),
                      letterSpacing: 0.4,
                    ),
                  )
                : _buildAnimatedTyping(fontSize),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTyping(double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'is typing',
          style: TextStyle(
            fontFamily: 'SF Compact Rounded',
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFB2B2B2),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: 8.0),
        _buildAnimatedDots(),
      ],
    );
  }

  Widget _buildAnimatedDots() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFFB2B2B2),
            const Color(0xFF888888),
            const Color(0xFFB2B2B2),
          ],
          stops: [
            0.0,
            _shimmerAnimation.value.clamp(0.0, 1.0),
            1.0,
          ],
        ).createShader(bounds);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBouncingDot(_dot1Animation),
          const SizedBox(width: RitualConfig.dotSpacing),
          _buildBouncingDot(_dot2Animation),
          const SizedBox(width: RitualConfig.dotSpacing),
          _buildBouncingDot(_dot3Animation),
        ],
      ),
    );
  }

  Widget _buildBouncingDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -8.0 * animation.value),
          child: Container(
            width: RitualConfig.dotSize,
            height: RitualConfig.dotSize,
            decoration: const BoxDecoration(
              color: Color(0xFFB2B2B2),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}