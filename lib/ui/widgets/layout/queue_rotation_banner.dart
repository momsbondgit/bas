import 'package:flutter/material.dart';
import '../../config/ritual_config.dart';
import '../../utils/animation_utils.dart';
import '../../utils/accessibility_utils.dart';

class QueueRotationBanner extends StatefulWidget {
  const QueueRotationBanner({
    super.key,
    required this.displayName,
    required this.isActiveUser,
    required this.onDismiss,
  });

  final String displayName;
  final bool isActiveUser;
  final VoidCallback onDismiss;

  @override
  State<QueueRotationBanner> createState() => _QueueRotationBannerState();
}

class _QueueRotationBannerState extends State<QueueRotationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimation();
    _scheduleAutoDismiss();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AnimationUtils.getAnimationDuration(
        context,
        RitualConfig.bannerAnimationDuration,
      ),
      vsync: this,
    );

    _slideAnimation = AnimationUtils.createSlideInAnimation(
      _animationController,
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    );

    _fadeAnimation = AnimationUtils.createFadeAnimation(_animationController);
  }

  void _startAnimation() {
    _animationController.forward();
    
    // Announce to screen readers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccessibilityUtils.announceToScreenReader(
        context,
        AccessibilityUtils.getRotationAnnouncementText(
          widget.displayName,
          widget.isActiveUser,
        ),
      );
    });
  }

  void _scheduleAutoDismiss() {
    Future.delayed(RitualConfig.bannerDisplayDuration, () {
      if (mounted) {
        _dismissBanner();
      }
    });
  }

  void _dismissBanner() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    final fontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * 0.038).clamp(14.0, 16.0));

    return AnimationUtils.shouldReduceMotion(context)
        ? _buildBannerContent(fontSize)
        : SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildBannerContent(fontSize),
            ),
          );
  }

  Widget _buildBannerContent(double fontSize) {
    final message = widget.isActiveUser
        ? RitualConfig.yourTurnBannerText
        : '${RitualConfig.newTurnBannerPrefix}${widget.displayName}';

    return AccessibilityUtils.wrapWithSemantics(
      label: AccessibilityUtils.getRotationAnnouncementText(
        widget.displayName,
        widget.isActiveUser,
      ),
      liveRegion: true,
      child: Container(
        width: double.infinity,
        height: RitualConfig.bannerHeight,
        decoration: BoxDecoration(
          color: widget.isActiveUser ? Colors.green.shade100 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(RitualConfig.bannerBorderRadius),
          border: Border.all(
            color: widget.isActiveUser ? Colors.green.shade300 : Colors.blue.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'SF Compact Rounded',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            IconButton(
              onPressed: _dismissBanner,
              icon: const Icon(
                Icons.close,
                color: Color(0xFFB2B2B2),
                size: 20,
              ),
              tooltip: 'Dismiss notification',
            ),
          ],
        ),
      ),
    );
  }
}