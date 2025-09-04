import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final String? text;
  final bool isLive;
  final bool isTimer;
  final bool isViewerCount;
  final int? viewerCount;
  final double? pulseValue;

  const StatusIndicator._({
    super.key,
    this.text,
    this.isLive = false,
    this.isTimer = false,
    this.isViewerCount = false,
    this.viewerCount,
    this.pulseValue,
  });

  factory StatusIndicator.live() {
    return const StatusIndicator._(
      text: 'LIVE',
      isLive: true,
    );
  }

  factory StatusIndicator.liveWithPulse(double pulseValue) {
    return StatusIndicator._(
      text: 'LIVE',
      isLive: true,
      pulseValue: pulseValue,
    );
  }

  factory StatusIndicator.timer(String time) {
    return StatusIndicator._(
      text: time,
      isTimer: true,
    );
  }

  factory StatusIndicator.viewerCount(int count) {
    return StatusIndicator._(
      text: count.toString(),
      isViewerCount: true,
      viewerCount: count,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive sizing
    final fontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * 0.038).clamp(14.0, 16.0));
    final horizontalPadding = isDesktop ? 14.0 : (isTablet ? 12.0 : (isViewerCount ? 5.0 : 11.0));
    final verticalPadding = isDesktop ? 8.0 : (isTablet ? 6.0 : 5.0);
    final iconSize = isDesktop ? 18.0 : (isTablet ? 17.0 : 16.0);
    final profileIconSize = isDesktop ? 24.0 : (isTablet ? 22.0 : 21.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFC).withOpacity(0.54),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isViewerCount) ...[
            // Profile picture from assets
            Container(
              width: profileIconSize,
              height: profileIconSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'Assets/eye.png',
                  width: profileIconSize,
                  height: profileIconSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image fails to load
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: profileIconSize * 0.75,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: isDesktop ? 2.0 : (isTablet ? 1.5 : 1.0)),
          ],
          
          Text(
            text ?? '',
            style: TextStyle(
              fontFamily: isViewerCount ? 'SF Pro Rounded' : 'SF Compact Rounded',
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              letterSpacing: 0.4,
            ),
          ),
          
          if (isLive) ...[
            SizedBox(width: isDesktop ? 10.0 : (isTablet ? 8.0 : 7.0)),
            Container(
              width: iconSize,
              height: iconSize - 1,
              decoration: BoxDecoration(
                color: Color(0xFFFF6262).withOpacity(
                  pulseValue != null ? 0.5 + (pulseValue! * 0.5) : 1.0
                ),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

