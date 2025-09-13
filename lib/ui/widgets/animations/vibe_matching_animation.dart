import 'package:flutter/material.dart';
import 'dart:math' as math;

class VibeMatchingAnimation extends StatefulWidget {
  final Map<int, String> vibeAnswers;
  final VoidCallback onAnimationComplete;
  final ValueChanged<double>? onProgressChanged;

  const VibeMatchingAnimation({
    super.key,
    required this.vibeAnswers,
    required this.onAnimationComplete,
    this.onProgressChanged,
  });

  @override
  State<VibeMatchingAnimation> createState() => _VibeMatchingAnimationState();
}

class _VibeMatchingAnimationState extends State<VibeMatchingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _shuffleController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shuffleAnimation;
  late Animation<double> _progressAnimation;

  final List<VibeCard> _cards = [];
  bool _showCards = false;
  bool _isShuffling = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shuffleController = AnimationController(
      duration: const Duration(milliseconds: 6000), // Slowed down from 4000ms to 6000ms
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 15000), // 15 seconds for full progress
      vsync: this,
    );


    // Create animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _shuffleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shuffleController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Add listener to notify parent of progress changes
    _progressController.addListener(() {
      widget.onProgressChanged?.call(_progressAnimation.value);
    });


    // Prepare cards data
    _prepareCards();

    // Start animation sequence
    _startAnimationSequence();
  }

  void _prepareCards() {
    final optionLabels = {
      'A': ['Already putting on the fit 💃', 'Say hi first and jump in the convo 👋', 'Pulling up receipts + clapping back 🔥'],
      'B': ['Staying in w snacks + Netflix 🍿', 'Kick back, let them come to you 😏', 'Laughing it off with the squad 💀'],
    };

    for (int i = 1; i <= 3; i++) {
      final answer = widget.vibeAnswers[i];
      if (answer != null) {
        final answerText = answer == 'A' ? optionLabels['A']![i - 1] : optionLabels['B']![i - 1];
        _cards.add(VibeCard(
          question: 'Q$i',
          answer: answerText,
          index: i - 1,
        ));
      }
    }
  }

  void _startAnimationSequence() async {
    // 1. Show cards immediately and start continuous shuffling
    setState(() {
      _showCards = true;
      _isShuffling = true;
    });

    // 2. Start continuous shuffling animation (never stops) and progress bar
    _shuffleController.repeat();
    _progressController.forward();

    // 3. Fade in heading while animation is running
    await _fadeController.forward();

    // 4. Wait for the full 15 seconds for user to see the animation
    await Future.delayed(const Duration(milliseconds: 15000));

    // 5. Complete without stopping animation - let it run continuously
    if (mounted) {
      widget.onAnimationComplete();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shuffleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Heading with fade animation
        FadeTransition(
          opacity: _fadeAnimation,
          child: const Text(
            'Finding people who match your vibe 🕵️‍♀️',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Cards animation area - centered
        if (_showCards)
          Center(
            child: SizedBox(
              height: 280,
              width: 280,
              child: Stack(
                alignment: Alignment.center,
                children: _cards.map((card) => _buildAnimatedCard(card)).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAnimatedCard(VibeCard card) {
    return AnimatedBuilder(
      animation: _shuffleController,
      builder: (context, child) {
        double x = 0;
        double y = 0;
        double rotation = 0;
        double scale = 1.0;

        if (_isShuffling) {
          // Continuous shuffling animation - cards move around randomly with slower, smoother motion
          final shuffleProgress = _shuffleAnimation.value;
          final randomSeed = card.index * 123.456; // Consistent randomness per card

          x = math.sin(shuffleProgress * math.pi * 2 + randomSeed) * 40; // Reduced speed and range
          y = math.cos(shuffleProgress * math.pi * 1.5 + randomSeed) * 25; // Reduced speed and range
          rotation = math.sin(shuffleProgress * math.pi * 1 + randomSeed) * 0.15; // Slower rotation
          scale = 0.95 + math.sin(shuffleProgress * math.pi * 3 + randomSeed) * 0.05; // Subtle scaling
        }

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(x, y)
            ..rotateZ(rotation)
            ..scale(scale),
          child: Container(
            width: 240,
            height: 100,
            margin: EdgeInsets.only(
              top: card.index * 5.0, // Minimal stacking offset
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E5E5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    card.question,
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    card.answer,
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      letterSpacing: 0.2,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VibeCard {
  final String question;
  final String answer;
  final int index;

  VibeCard({
    required this.question,
    required this.answer,
    required this.index,
  });
}