import 'package:flutter/material.dart';

class MessageAreaTypingIndicator extends StatefulWidget {
  final String username;
  final bool isVisible;
  final Duration animationDuration;
  final Color dotColor;
  final double dotSize;
  
  const MessageAreaTypingIndicator({
    super.key,
    required this.username,
    required this.isVisible,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.dotColor = const Color(0xFF8F8F8F),
    this.dotSize = 6.0,
  });

  @override
  State<MessageAreaTypingIndicator> createState() => _MessageAreaTypingIndicatorState();
}

class _MessageAreaTypingIndicatorState extends State<MessageAreaTypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(MessageAreaTypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        if (_fadeAnimation.value == 0.0) {
          return const SizedBox.shrink();
        }
        
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.username} is typing',
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFF8F8F8F),
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16.0),
                _TypingDotsAnimation(
                  dotColor: widget.dotColor,
                  dotSize: widget.dotSize,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TypingDotsAnimation extends StatefulWidget {
  final Color dotColor;
  final double dotSize;
  
  const _TypingDotsAnimation({
    required this.dotColor,
    required this.dotSize,
  });

  @override
  State<_TypingDotsAnimation> createState() => _TypingDotsAnimationState();
}

class _TypingDotsAnimationState extends State<_TypingDotsAnimation>
    with TickerProviderStateMixin {
  late AnimationController _dotsAnimationController;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _dotsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _dotAnimations = List.generate(3, (index) {
      final startTime = index * 0.2;
      return Tween<double>(
        begin: 0.4,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _dotsAnimationController,
        curve: Interval(
          startTime,
          startTime + 0.4,
          curve: Curves.easeInOut,
        ),
      ));
    });

    _dotsAnimationController.repeat();
  }

  @override
  void dispose() {
    _dotsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _dotAnimations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(right: index < 2 ? 4.0 : 0.0),
              child: Opacity(
                opacity: _dotAnimations[index].value,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}