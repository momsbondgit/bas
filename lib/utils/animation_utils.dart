import 'package:flutter/material.dart';
import '../config/ritual_config.dart';

class AnimationUtils {
  static Animation<double> createBounceAnimation(
    AnimationController controller,
    int dotIndex,
  ) {
    final offset = RitualConfig.animationStaggerOffsets['dot$dotIndex'] ?? 0;
    final begin = offset / RitualConfig.dotBounceDuration.inMilliseconds;
    final end = (offset + 200) / RitualConfig.dotBounceDuration.inMilliseconds;
    
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          begin.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: Curves.elasticOut,
        ),
      ),
    );
  }

  static Animation<double> createShimmerAnimation(AnimationController controller) {
    return Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  static Animation<Offset> createSlideInAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0.0, -1.0),
    Offset end = Offset.zero,
  }) {
    return Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ),
    );
  }

  static Animation<double> createFadeAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 0.8,
    double end = 1.0,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  static bool shouldReduceMotion(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.disableAnimations;
  }

  static Duration getAnimationDuration(
    BuildContext context,
    Duration originalDuration,
  ) {
    if (shouldReduceMotion(context)) {
      return Duration.zero;
    }
    return originalDuration;
  }

  static Curve getAnimationCurve(BuildContext context, Curve originalCurve) {
    if (shouldReduceMotion(context)) {
      return Curves.linear;
    }
    return originalCurve;
  }
}