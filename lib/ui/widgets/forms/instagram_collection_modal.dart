import 'package:flutter/material.dart';
import '../../../services/core/ending_service.dart';

class InstagramCollectionModal extends StatefulWidget {
  final VoidCallback? onInstagramSubmitted;

  const InstagramCollectionModal({
    super.key,
    this.onInstagramSubmitted,
  });

  @override
  State<InstagramCollectionModal> createState() => _InstagramCollectionModalState();
}

class _InstagramCollectionModalState extends State<InstagramCollectionModal> {
  final TextEditingController _instagramController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  final EndingService _endingService = EndingService();

  @override
  void dispose() {
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _endingService.saveRejectedUserInstagram(_instagramController.text.trim());

      if (mounted) {
        setState(() {
          _isSubmitted = true;
        });
        widget.onInstagramSubmitted?.call();
      }
    } catch (e) {
      // Handle error if needed
      print('Error saving Instagram: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  TextStyle _getTextStyle({required Color color}) {
    return TextStyle(
      fontFamily: 'SF Pro',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: 0.4,
    );
  }

  OutlineInputBorder _getInputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Check if popup would overflow when keyboard appears
    final popupMaxHeight = screenHeight * 0.8;
    final availableHeight = screenHeight - keyboardHeight;
    final needsScrolling = keyboardHeight > 0 && popupMaxHeight > availableHeight;

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
            child: needsScrolling
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    _isSubmitted ? 'thank you! ✨' : 'world is full!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message
                  if (!_isSubmitted)
                    Text(
                      'if we already have your instagram we\'ll send you the next code soon. if not, drop it below and we\'ll make you a member!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.4,
                      ),
                    ),

                  if (!_isSubmitted) ...[
                    const SizedBox(height: 24),

                    // Instagram label
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ur instagram:',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Instagram input
                    TextFormField(
                      controller: _instagramController,
                      decoration: InputDecoration(
                        hintText: 'your_username',
                        hintStyle: _getTextStyle(color: const Color(0xFFB2B2B2)),
                        prefixText: '@',
                        prefixStyle: _getTextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: _getInputBorder(const Color(0xFFB2B2B2)),
                        enabledBorder: _getInputBorder(const Color(0xFFB2B2B2)),
                        focusedBorder: _getInputBorder(Colors.black),
                        errorBorder: _getInputBorder(Colors.red),
                        focusedErrorBorder: _getInputBorder(Colors.red),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: _getTextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your Instagram handle';
                        }
                        return null;
                      },
                      enabled: !_isSubmitting,
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    GestureDetector(
                      onTap: _isSubmitting ? null : _handleSubmit,
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _isSubmitting ? const Color(0xFF666666) : Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'submit',
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
                  ] else ...[
                    const SizedBox(height: 40),
                    // Success state - just show the thank you message
                    const Text(
                      '💕',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32),
                    ),
                  ],
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          _isSubmitted ? 'thank you! ✨' : 'world is full!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Message
                        if (!_isSubmitted)
                          Text(
                            'if we already have your instagram we\'ll send you the next code soon. if not, drop it below and we\'ll make you a member!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.4,
                            ),
                          ),

                        if (!_isSubmitted) ...[
                          const SizedBox(height: 24),

                          // Instagram label
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'ur instagram:',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Instagram input
                          TextFormField(
                            controller: _instagramController,
                            decoration: InputDecoration(
                              hintText: 'your_username',
                              hintStyle: _getTextStyle(color: const Color(0xFFB2B2B2)),
                              prefixText: '@',
                              prefixStyle: _getTextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.white,
                              border: _getInputBorder(const Color(0xFFB2B2B2)),
                              enabledBorder: _getInputBorder(const Color(0xFFB2B2B2)),
                              focusedBorder: _getInputBorder(Colors.black),
                              errorBorder: _getInputBorder(Colors.red),
                              focusedErrorBorder: _getInputBorder(Colors.red),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: _getTextStyle(color: Colors.black),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your Instagram handle';
                              }
                              return null;
                            },
                            enabled: !_isSubmitting,
                          ),
                          const SizedBox(height: 24),

                          // Submit button
                          GestureDetector(
                            onTap: _isSubmitting ? null : _handleSubmit,
                            child: Container(
                              width: double.infinity,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _isSubmitting ? const Color(0xFF666666) : Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'submit',
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
                        ] else ...[
                          const SizedBox(height: 40),
                          // Success state - just show the thank you message
                          const Text(
                            '💕',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 32),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}