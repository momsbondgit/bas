import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../../models/user/bot_user.dart';
import '../../../models/user/queue_user.dart';
import '../../../config/world_config.dart';
import '../../../services/auth/auth_service.dart';
import '../../../services/data/local_storage_service.dart';

class GoodbyePopupModal extends StatefulWidget {
  final WorldConfig worldConfig;
  final List<BotUser> assignedBots;
  final VoidCallback onComplete;

  const GoodbyePopupModal({
    super.key,
    required this.worldConfig,
    required this.assignedBots,
    required this.onComplete,
  });

  @override
  State<GoodbyePopupModal> createState() => _GoodbyePopupModalState();
}

class _GoodbyePopupModalState extends State<GoodbyePopupModal> with TickerProviderStateMixin {
  late Timer _timer;
  int _remainingSeconds = 33;
  final TextEditingController _goodbyeController = TextEditingController();
  final List<GoodbyeMessage> _goodbyeMessages = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(seconds: 10), // 10 second fade duration
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0, // Start fully visible
      end: 0.0,   // End fully transparent
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _startTimer();
    _addBotGoodbyes();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      // Start fade-out animation when 10 seconds remain
      if (_remainingSeconds == 10) {
        _fadeController.forward();
      }

      if (_remainingSeconds <= 0) {
        _timer.cancel();
        widget.onComplete();
      }
    });
  }

  void _addBotGoodbyes() {
    // Add bot goodbye messages with realistic delays
    final random = Random();
    int cumulativeDelay = 6000; // First bot message after 6 seconds

    for (int i = 0; i < widget.assignedBots.length; i++) {
      final bot = widget.assignedBots[i];
      Timer(Duration(milliseconds: cumulativeDelay), () {
        if (mounted) {
          _addGoodbyeMessage(bot.nickname, _getRandomGoodbyeText(bot), isBot: true);
        }
      });

      // Add random 2.5-3.5 second delay for next bot (2500-3500ms)
      cumulativeDelay += 2500 + random.nextInt(1001);
    }
  }

  String _getRandomGoodbyeText(BotUser bot) {
    return bot.goodbyeText;
  }

  void _addGoodbyeMessage(String username, String message, {bool isBot = false}) {
    final goodbyeMessage = GoodbyeMessage(
      username: username,
      message: message,
      isBot: isBot,
      timestamp: DateTime.now(),
    );

    setState(() {
      _goodbyeMessages.add(goodbyeMessage);
    });
  }

  void _submitGoodbye() async {
    // Don't allow submissions when fading out (last 4 seconds)
    if (_remainingSeconds <= 4) return;

    final message = _goodbyeController.text.trim();
    if (message.isNotEmpty) {
      _addGoodbyeMessage('You', message);
      _goodbyeController.clear();

      // Store goodbye message in Firebase
      try {
        final localStorageService = LocalStorageService();
        final authService = AuthService();
        final userId = await localStorageService.getAnonId();

        if (userId != null && userId.isNotEmpty) {
          await authService.storeGoodbyeMessage(userId, message);
        }
      } catch (e) {
        // Continue anyway - don't block user experience
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _goodbyeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Check if popup would overflow when keyboard appears
    const popupHeight = 500.0;
    final availableHeight = screenHeight - keyboardHeight;
    final needsScrolling = keyboardHeight > 0 && popupHeight > availableHeight;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: 350,
            height: 500,
            decoration: BoxDecoration(
            color: const Color(0xFFF1EDEA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFB2B2B2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                offset: const Offset(0, 8),
                blurRadius: 32,
              ),
            ],
          ),
          child: needsScrolling
              ? SingleChildScrollView(
                  child: Column(
                    children: [
            // Header with timer
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'say ur byes 💕',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_remainingSeconds seconds remaining',
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Live goodbye messages area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E5E5),
                    width: 1,
                  ),
                ),
                child: _goodbyeMessages.isEmpty
                    ? const Center(
                        child: Text(
                          'drop a quick bye 👋',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 16,
                            color: Color(0xFF8F8F8F),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        reverse: true, // Show newest messages at bottom
                        itemCount: _goodbyeMessages.length,
                        itemBuilder: (context, index) {
                          final message = _goodbyeMessages[_goodbyeMessages.length - 1 - index];
                          return _buildGoodbyeMessageCard(message);
                        },
                      ),
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFFE5E5E5),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _goodbyeController,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          hintText: 'drop a quick bye 👋',
                          hintStyle: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 14,
                            color: Color(0xFF8F8F8F),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          counterText: '',
                        ),
                        style: const TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        onSubmitted: (_) => _submitGoodbye(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _submitGoodbye,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _remainingSeconds <= 4
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        color: _remainingSeconds <= 4
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header with timer
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'say ur byes 💕',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$_remainingSeconds seconds remaining',
                              style: const TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Live goodbye messages area
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E5E5),
                            width: 1,
                          ),
                        ),
                        child: _goodbyeMessages.isEmpty
                            ? const Center(
                                child: Text(
                                  'drop a quick bye 👋',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontSize: 16,
                                    color: Color(0xFF8F8F8F),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                reverse: true, // Show newest messages at bottom
                                itemCount: _goodbyeMessages.length,
                                itemBuilder: (context, index) {
                                  final message = _goodbyeMessages[_goodbyeMessages.length - 1 - index];
                                  return _buildGoodbyeMessageCard(message);
                                },
                              ),
                      ),
                    ),

                    // Input area
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: const Color(0xFFE5E5E5),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _goodbyeController,
                                maxLength: 100,
                                decoration: const InputDecoration(
                                  hintText: 'drop a quick bye 👋',
                                  hintStyle: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontSize: 14,
                                    color: Color(0xFF8F8F8F),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  counterText: '',
                                ),
                                style: const TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                onSubmitted: (_) => _submitGoodbye(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _submitGoodbye,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _remainingSeconds <= 4
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.send,
                                color: _remainingSeconds <= 4
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          ),
        ),
      );
  }

  Widget _buildGoodbyeMessageCard(GoodbyeMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.username,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message.message,
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 14,
              color: Colors.black,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class GoodbyeMessage {
  final String username;
  final String message;
  final bool isBot;
  final DateTime timestamp;

  GoodbyeMessage({
    required this.username,
    required this.message,
    required this.isBot,
    required this.timestamp,
  });
}