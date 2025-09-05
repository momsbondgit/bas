import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/world_config.dart';

class WorldAccessModal extends StatefulWidget {
  final WorldConfig? worldConfig;
  final Function(String accessCode, String nickname) onSubmit;
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

  @override
  void dispose() {
    _accessCodeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    // Clear previous access code error
    setState(() {
      _accessCodeError = null;
    });
    
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(
        _accessCodeController.text.trim(),
        _nicknameController.text.trim(),
      );
    } catch (e) {
      // If onSubmit throws an error or returns false, show inline error
      if (mounted) {
        setState(() {
          _accessCodeError = 'wrong code, try again';
        });
        // Trigger form validation to show the error
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenWidth > 400 ? 350 : screenWidth * 0.85,
        padding: const EdgeInsets.all(24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
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
              
              // Description
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
              
              // Access Code Field
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
              
              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _isSubmitting ? null : widget.onCancel,
                      child: Container(
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
                            'nah, maybe later',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: _isSubmitting 
                                  ? const Color(0xFFB2B2B2) 
                                  : Colors.black,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Submit Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _isSubmitting ? null : _handleSubmit,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}