import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/world_config.dart';
import '../animations/vibe_matching_animation.dart';

class WorldAccessModal extends StatefulWidget {
  final WorldConfig? worldConfig;
  final Function(String accessCode, String nickname, Map<int, String> vibeAnswers) onSubmit;
  final VoidCallback? onCancel;

  const WorldAccessModal({
    super.key,
    this.worldConfig,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<WorldAccessModal> createState() => _WorldAccessModalState();
}

class _WorldAccessModalState extends State<WorldAccessModal> {
  final TextEditingController _accessCodeController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _accessCodeError;

  // Multi-step state
  int _currentStep = 1; // 1=code+nickname, 2=vibe check, 3=vibe matching
  final Map<int, String> _vibeAnswers = {}; // Q1, Q2, Q3 answers
  int _currentVibeQuestion = 1;
  String? _selectedOption; // Track which option is selected for current question
  double _vibeMatchingProgress = 0.0; // Track vibe matching animation progress



  @override
  void dispose() {
    _accessCodeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _handleNextStep() async {
    if (_currentStep == 1) {
      // Validate both access code and nickname
      setState(() {
        _accessCodeError = null;
      });

      if (!_formKey.currentState!.validate()) return;

      // Move to vibe check
      setState(() {
        _currentStep = 2;
        _currentVibeQuestion = 1;
      });
    } else if (_currentStep == 2) {
      // Move to vibe matching animation step
      setState(() {
        _currentStep = 3;
      });
    } else if (_currentStep == 3) {
      // Submit everything (this happens after vibe matching animation)
      setState(() {
        _isSubmitting = true;
      });

      try {
        await widget.onSubmit(
          _accessCodeController.text.trim(),
          _nicknameController.text.trim(),
          _vibeAnswers,
        );
      } catch (e) {
        // If onSubmit throws an error, go back to step 1
        if (mounted) {
          setState(() {
            _accessCodeError = 'wrong code, try again';
            _currentStep = 1;
          });
          _formKey.currentState!.validate();
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  void _handleBack() {
    if (_currentStep == 2) {
      // Handle back within vibe check
      if (_currentVibeQuestion > 1) {
        // Go to previous vibe question
        setState(() {
          _currentVibeQuestion--;
          // Remove the answer for the current question when going back
          _vibeAnswers.remove(_currentVibeQuestion + 1);
        });
      } else {
        // Go back to step 1
        setState(() {
          _currentStep = 1;
          _currentVibeQuestion = 1;
          _vibeAnswers.clear();
        });
      }
    } else if (_currentStep > 1) {
      // Handle back for other steps
      setState(() {
        _currentStep--;
        // Reset vibe check when going back from step 2
        if (_currentStep == 1) {
          _currentVibeQuestion = 1;
          _vibeAnswers.clear();
        }
      });
    }
  }

  void _handleVibeAnswer(String answer) async {
    // First, show the selection feedback
    setState(() {
      _selectedOption = answer;
      _vibeAnswers[_currentVibeQuestion] = answer;
    });

    // Wait a moment for the visual feedback
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      setState(() {
        _selectedOption = null; // Reset selection for next question
      });

      if (_currentVibeQuestion < 3) {
        // Move to next vibe question
        setState(() {
          _currentVibeQuestion++;
        });
      } else {
        // All questions answered, move to vibe matching animation
        _handleNextStep();
      }
    }
  }

  String? _validateAccessCode(String? value) {
    // Show access code validation error if present
    if (_accessCodeError != null) {
      return _accessCodeError;
    }
    
    if (value == null || value.trim().isEmpty) {
      return 'ur access code is required bestie';
    }
    if (value.trim().length != 3) {
      return 'needs to be exactly 3 numbers';
    }
    if (!RegExp(r'^\d{3}$').hasMatch(value.trim())) {
      return 'numbers only pls';
    }
    return null;
  }

  String? _validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'we gotta call u something!';
    }
    if (value.trim().length > 20) {
      return 'keep it under 20 chars bestie';
    }
    return null;
  }

  Widget _buildProgressBar() {
    // Calculate total steps: 1 (code+nickname) + 3 (vibe questions) + 1 (vibe matching) = 5 total
    int totalSteps = 5;
    int currentStepNumber = 1;

    if (_currentStep == 1) {
      currentStepNumber = 1; // Access code + nickname
    } else if (_currentStep == 2) {
      currentStepNumber = 1 + _currentVibeQuestion; // 1 + (1,2,3) = 2,3,4
    } else if (_currentStep == 3) {
      currentStepNumber = 5; // Vibe matching animation
    }

    // For step 3 (vibe matching), use the animation progress instead of fixed step progress
    final progress = _currentStep == 3
        ? (4.0 + _vibeMatchingProgress) / totalSteps  // Start at 4/5 and progress to 5/5
        : currentStepNumber / totalSteps;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStepNumber of $totalSteps',
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFFE5E5E5),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
          minHeight: 3,
        ),
      ],
    );
  }

  Widget _getCurrentStepContent() {
    if (_currentStep == 1) {
      return _buildStep1Content();
    } else if (_currentStep == 2) {
      return _buildVibeCheckStep();
    } else if (_currentStep == 3) {
      return VibeMatchingAnimation(
        vibeAnswers: _vibeAnswers,
        onAnimationComplete: _handleNextStep,
        onProgressChanged: (progress) {
          setState(() {
            _vibeMatchingProgress = progress;
          });
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step 1: Access Code
        Center(
          child: Text(
            widget.worldConfig?.modalTitle ?? 'join the world bestie ✨',
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.worldConfig?.modalDescription != null)
          Center(
            child: Text(
              widget.worldConfig!.modalDescription!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
                letterSpacing: 0.4,
              ),
            ),
          ),
        const SizedBox(height: 24),
        const Text(
          'ur access code:',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _accessCodeController,
          keyboardType: TextInputType.number,
          maxLength: 3,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          validator: _validateAccessCode,
          decoration: InputDecoration(
            hintText: '123',
            hintStyle: const TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFB2B2B2),
              letterSpacing: 0.4,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFB2B2B2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFB2B2B2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 20),

        // Nickname Field
        const Text(
          'what should we call u?',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            letterSpacing: 0.4,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: _nicknameController,
          maxLength: 20,
          validator: _validateNickname,
          decoration: InputDecoration(
            hintText: 'ur nickname here...',
            hintStyle: const TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFB2B2B2),
              letterSpacing: 0.4,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFB2B2B2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFB2B2B2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            letterSpacing: 0.4,
          ),
        ),

        const SizedBox(height: 24),

        // Next button for step 1
        GestureDetector(
          onTap: _isSubmitting ? null : _handleNextStep,
          child: Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'let\'s goooo',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVibeCheckStep() {
    final questions = [
      {
        'question': 'When dorm drama pops off right in front of me, I usually…',
        'optionA': 'Gas it up like "nahh that\'s crazyyy" 🍿',
        'optionB': 'Pull my bestie aside later with all the tea 💌',
      },
      {
        'question': 'Friday night, you\'ll catch me…',
        'optionA': 'Out with the girls till 2 AM 💃',
        'optionB': 'Cozy night in w/ face masks + shows 🛏️',
      },
      {
        'question': 'When the GC goes silent, I usually…',
        'optionA': 'Drop a random meme 🤡',
        'optionB': 'Wait for someone else to revive it 💤',
      },
    ];

    final currentQ = questions[_currentVibeQuestion - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'vibe check ✨',
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Question $_currentVibeQuestion of 3',
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          currentQ['question']!,
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 24),
        // Option A
        GestureDetector(
          onTap: () => _handleVibeAnswer('A'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedOption == 'A' ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedOption == 'A' ? Colors.black : const Color(0xFFB2B2B2),
                width: 1,
              ),
            ),
            child: Text(
              currentQ['optionA']!,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _selectedOption == 'A' ? Colors.white : Colors.black,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Option B
        GestureDetector(
          onTap: () => _handleVibeAnswer('B'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedOption == 'B' ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedOption == 'B' ? Colors.black : const Color(0xFFB2B2B2),
                width: 1,
              ),
            ),
            child: Text(
              currentQ['optionB']!,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _selectedOption == 'B' ? Colors.white : Colors.black,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Back button - show for all vibe questions
          GestureDetector(
            onTap: _handleBack,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFB2B2B2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _currentVibeQuestion == 1 ? '← back' : '← previous',
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Bar
                _buildProgressBar(),
                const SizedBox(height: 24),

                // Dynamic content based on step
                _getCurrentStepContent(),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}