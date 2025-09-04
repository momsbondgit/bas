import 'package:flutter/material.dart';
import '../../services/core/ending_service.dart';

void main() {
  runApp(const SessionEndApp());
}

class SessionEndApp extends StatelessWidget {
  const SessionEndApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Session End Screen',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SessionEndScreen(),
    );
  }
}


class SessionEndScreen extends StatefulWidget {
  const SessionEndScreen({super.key});

  @override
  State<SessionEndScreen> createState() => _SessionEndScreenState();
}

class _SessionEndScreenState extends State<SessionEndScreen> {
  final TextEditingController _numberController = TextEditingController();
  final EndingService _endingService = EndingService();
  bool _isSending = false;

  void _onSendPressed() async {
    if (_numberController.text.trim().isEmpty || _isSending) return;
    
    final phoneNumber = _numberController.text.trim();
    
    setState(() {
      _isSending = true;
    });
    
    try {
      await _endingService.savePhoneNumber(phoneNumber);
      _numberController.clear();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving phone number: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive padding
    final horizontalPadding = isDesktop ? screenWidth * 0.15 : (isTablet ? screenWidth * 0.1 : screenWidth * 0.055);
    final verticalPadding = isDesktop ? 40.0 : (isTablet ? 35.0 : screenHeight * 0.04);
    
    
    // Font sizes
    final bodyFontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : (screenWidth * 0.04).clamp(14.0, 16.0));
    final inputFontSize = isDesktop ? 20.0 : (isTablet ? 19.0 : (screenWidth * 0.05).clamp(18.0, 20.0));
    final buttonFontSize = isDesktop ? 14.0 : (isTablet ? 13.0 : (screenWidth * 0.035).clamp(12.0, 14.0));
    
    // Input field dimensions
    final inputHeight = isDesktop ? 60.0 : (isTablet ? 55.0 : (screenHeight * 0.065).clamp(50.0, 60.0));
    final buttonWidth = isDesktop ? 80.0 : (isTablet ? 70.0 : (screenWidth * 0.18).clamp(60.0, 75.0));
    final buttonHeight = isDesktop ? 40.0 : (isTablet ? 36.0 : (screenHeight * 0.045).clamp(32.0, 40.0));

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1EDEA),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main text content
                Text(
                  'Alright...that\'s it. Go back to pretending you\'re normal.',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    letterSpacing: 0.4,
                    height: 1.4,
                  ),
                ),
                
                SizedBox(height: isDesktop ? 30.0 : (isTablet ? 25.0 : (screenHeight * 0.03).clamp(20.0, 30.0))),
                
                Text(
                  'Next round: campus crushes. If you\'re in, drop your number and when it\'s time we\'ll send the link.',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    letterSpacing: 0.4,
                    height: 1.4,
                  ),
                ),
                
                SizedBox(height: isDesktop ? 50.0 : (isTablet ? 45.0 : (screenHeight * 0.055).clamp(35.0, 50.0))),
                
                // Input field with send button
                Container(
                  height: inputHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EDEA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFB2B2B2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Text input
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: isDesktop ? 24.0 : (isTablet ? 20.0 : 20.0),
                            right: isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0),
                          ),
                          child: TextField(
                            controller: _numberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Number....',
                              hintStyle: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: inputFontSize,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFB2B2B2),
                                letterSpacing: 0.4,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: inputFontSize,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                      
                      // Send button
                      Padding(
                        padding: EdgeInsets.only(
                          right: isDesktop ? 20.0 : (isTablet ? 18.0 : 16.0),
                        ),
                        child: GestureDetector(
                          onTap: _onSendPressed,
                          child: Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
_isSending ? 'sending...' : 'send',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: isDesktop ? 30.0 : (isTablet ? 25.0 : (screenHeight * 0.025).clamp(18.0, 25.0))),
                
                // Bottom text
                Text(
                  'Don\'t snitch to the RAs.',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    letterSpacing: 0.4,
                    height: 1.4,
                  ),
                ),
                
                // Spacer to push content up slightly
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}