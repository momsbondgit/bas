import 'package:flutter/material.dart';
import 'dart:ui';
import 'girl_meets_college_screen.dart';
import '../../services/auth_service.dart';
import '../widgets/world_access_modal.dart';

void main() => runApp(MaterialApp(home: GeneralScreen()));

class GeneralScreen extends StatelessWidget {
  const GeneralScreen({super.key});

  Future<void> _checkAuthAndNavigate(BuildContext context) async {
    final authService = AuthService();
    
    // Check if user already has an account
    final isLoggedIn = await authService.isLoggedIn();
    
    if (isLoggedIn) {
      // User has account, navigate directly
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GirlMeetsCollegeScreen(selectedFloor: 1),
          ),
        );
      }
    } else {
      // User needs to create account, show modal
      if (context.mounted) {
        _showWorldAccessModal(context);
      }
    }
  }

  void _showWorldAccessModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WorldAccessModal(
        onSubmit: (accessCode, nickname) async {
          final authService = AuthService();
          final success = await authService.createAccount(accessCode, nickname);
          
          if (success && context.mounted) {
            Navigator.of(context).pop(); // Close modal
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GirlMeetsCollegeScreen(selectedFloor: 1),
              ),
            );
          } else if (context.mounted) {
            // Show error - could enhance this with better error handling
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('something went wrong bestie, try again'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          _buildFadeBackground(context),
          GestureDetector(
            onTap: () => _checkAuthAndNavigate(context),
            child: Stack(
              children: [
                _buildBox(context),
                _buildStickerImage(context),
                _buildTapImage(context),
              ],
            ),
          ),
          _buildTitle(context),
        ],
      ),
    );
  }

  Widget _buildFadeBackground(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final groupWidth = 124.0;
    final groupHeight = 128.0;
    
    // Center the background group on screen
    return Positioned(
      left: (screenSize.width - groupWidth) / 2,
      top: (screenSize.height - groupHeight) / 2,
      child: SizedBox(
        width: groupWidth,
        height: groupHeight,
        child: Stack(
          children: [
            // Circle 1: #F9D6D3 at (39,39)
            Positioned(
              left: 39,
              top: 39,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 32.5, sigmaY: 32.5),
                child: Container(
                  width: 85,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF9D6D3).withOpacity(0.83),
                  ),
                ),
              ),
            ),
            // Circle 2: #FDBFC5 at (25,0)
            Positioned(
              left: 25,
              top: 0,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 32.5, sigmaY: 32.5),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFDBFC5).withOpacity(0.83),
                  ),
                ),
              ),
            ),
            // Circle 3: #FDC4A0 at (0,54)
            Positioned(
              left: 0,
              top: 54,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 32.5, sigmaY: 32.5),
                child: Container(
                  width: 77,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFDC4A0).withOpacity(0.83),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final boxWidth = 122.0;
    final boxHeight = 126.0;
    
    // Center the box on screen
    return Positioned(
      left: (screenSize.width - boxWidth) / 2,
      top: (screenSize.height - boxHeight) / 2,
      child: Container(
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFefd),
          border: Border.all(
            color: const Color(0xFFEFEFEF),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.07),
              offset: const Offset(4, 6),
              blurRadius: 8.9,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerImage(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Position the sticker image relative to the centered layout
    // In Figma it's at (120, 373) relative to frame, overlapping with the centered box area
    return Positioned(
      left: (screenSize.width / 2) - 80, // Position to the left of center
      top: (screenSize.height / 2) - 55, // Position even higher above center
      child: Image.asset(
        'assets/sticker_image.png',
        width: 165.29,
        height: 113.53,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTapImage(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Position the tap image relative to the centered layout
    // In Figma it's at (244, 267) relative to frame, which is to the right of the box
    return Positioned(
      left: (screenSize.width / 2) + 60, // Position slightly left of previous position
      top: (screenSize.height / 2) - 150, // Position much higher above center
      child: Image.asset(
        'assets/tap.png',
        width: 98,
        height: 98,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final boxHeight = 126.0;
    
    // Center the title horizontally and position it below the centered box
    return Positioned(
      left: 0,
      right: 0,
      top: (screenSize.height / 2) + (boxHeight / 2) + 15, // Position below centered box with padding
      child: const Center(
        child: Text(
          'Girl Meets College',
          style: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Color(0xFFB2B2B2),
          ),
        ),
      ),
    );
  }
}