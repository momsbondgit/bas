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
  final TextEditingController _instagramController = TextEditingController();
  final EndingService _endingService = EndingService();
  bool _isInstagramSending = false;


  void _onInstagramSendPressed() async {
    final instagramHandle = _instagramController.text.trim();
    
    if (instagramHandle.isEmpty || _isInstagramSending) return;
    
    setState(() {
      _isInstagramSending = true;
    });
    
    try {
      await _endingService.saveContactInfo(instagramHandle);
      _instagramController.clear();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Instagram handle saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving Instagram handle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInstagramSending = false;
        });
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onSendPressed,
    required bool isSending,
    required TextInputType keyboardType,
    required double inputHeight,
    required double inputFontSize,
    required double buttonWidth,
    required double buttonHeight,
    required double buttonFontSize,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return Container(
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: isDesktop ? 24.0 : (isTablet ? 20.0 : 20.0),
                right: isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0),
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hintText,
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
          Padding(
            padding: EdgeInsets.only(
              right: isDesktop ? 20.0 : (isTablet ? 18.0 : 16.0),
            ),
            child: GestureDetector(
              onTap: onSendPressed,
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isSending ? 'sending...' : 'send',
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
    );
  }

  @override
  void dispose() {
    _instagramController.dispose();
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
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Title
                Text(
                  'Lions Gate Baddies Only 🔒',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: bodyFontSize * 1.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 0.4,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: isDesktop ? 30.0 : (isTablet ? 25.0 : 20.0)),

                // Divider after title
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFFE0E0E0),
                ),

                SizedBox(height: isDesktop ? 30.0 : (isTablet ? 25.0 : 20.0)),

                // Instagram section
                Text(
                  'If you\'re new here → Drop your @ so we can make you a member.',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    letterSpacing: 0.4,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: isDesktop ? 20.0 : (isTablet ? 18.0 : 15.0)),

                // Instagram input field
                _buildInputField(
                  controller: _instagramController,
                  hintText: 'Instagram....',
                  onSendPressed: _onInstagramSendPressed,
                  isSending: _isInstagramSending,
                  keyboardType: TextInputType.text,
                  inputHeight: inputHeight,
                  inputFontSize: inputFontSize,
                  buttonWidth: buttonWidth,
                  buttonHeight: buttonHeight,
                  buttonFontSize: buttonFontSize,
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                ),

                SizedBox(height: isDesktop ? 35.0 : (isTablet ? 30.0 : 25.0)),

                // Divider after Instagram input
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFFE0E0E0),
                ),

                SizedBox(height: isDesktop ? 30.0 : (isTablet ? 25.0 : 20.0)),

                // Already a member text
                Text(
                  'If you\'re already a member → We\'ll send you the next code — you better be guarding that code like your life depends on it lmfaoo 😭',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    letterSpacing: 0.4,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: isDesktop ? 35.0 : (isTablet ? 30.0 : 25.0)),

                // Divider before footer
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFFE0E0E0),
                ),

                SizedBox(height: isDesktop ? 25.0 : (isTablet ? 20.0 : 15.0)),

                // Footer note
                Text(
                  'Members invite only. Don\'t share with lames.',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: bodyFontSize * 0.9,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.7),
                    letterSpacing: 0.4,
                    height: 1.4,
                  ),
                ),

                // Add some bottom spacing
                const SizedBox(height: 20),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}