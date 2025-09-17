import 'package:flutter/material.dart';
import 'dart:async';

class TribeLoadingModal extends StatefulWidget {
  final VoidCallback onComplete;

  const TribeLoadingModal({
    super.key,
    required this.onComplete,
  });

  @override
  State<TribeLoadingModal> createState() => _TribeLoadingModalState();
}

class _TribeLoadingModalState extends State<TribeLoadingModal> {
  Timer? _timer;
  int _secondsRemaining = 10;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false, // Prevent closing
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: screenWidth > 400 ? 350 : screenWidth * 0.85,
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF1EDEA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFB2B2B2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                // Main text
                const Text(
                  'waiting for your tribe to join ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 40),
                // Loading indicator
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}