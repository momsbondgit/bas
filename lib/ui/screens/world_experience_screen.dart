import 'package:flutter/material.dart';
import 'dart:ui';
import '../../config/world_config.dart';
import '../../services/world_service.dart';
import '../../services/auth/auth_service.dart';
import 'game_experience_screen.dart';

class WorldExperienceScreen extends StatefulWidget {
  final int selectedFloor;
  final WorldConfig? worldConfig;
  
  const WorldExperienceScreen({
    super.key,
    required this.selectedFloor,
    this.worldConfig,
  });

  @override
  State<WorldExperienceScreen> createState() => _WorldExperienceScreenState();
}

class _WorldExperienceScreenState extends State<WorldExperienceScreen> with TickerProviderStateMixin {
  // World configuration
  WorldConfig? _currentWorldConfig;
  
  @override
  void initState() {
    super.initState();
    // This screen now serves as a world selection interface
    // No complex initialization needed
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          _buildBackgroundCollages(context),
          _buildWorldTiles(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundCollages(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Girl Meets College background (left side)
        _buildFadeBackground(context, isLeft: true),
        // Guy Meets College background (right side)  
        _buildFadeBackground(context, isLeft: false),
      ],
    );
  }

  Widget _buildFadeBackground(BuildContext context, {required bool isLeft}) {
    final screenSize = MediaQuery.of(context).size;
    final groupWidth = 124.0;
    final groupHeight = 128.0;
    
    // Position on left or right side
    final leftOffset = isLeft 
        ? (screenSize.width / 4) - (groupWidth / 2)
        : (3 * screenSize.width / 4) - (groupWidth / 2);
    
    return Positioned(
      left: leftOffset,
      top: (screenSize.height - groupHeight) / 2,
      child: SizedBox(
        width: groupWidth,
        height: groupHeight,
        child: Stack(
          children: [
            // Circle 1
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
                    color: isLeft 
                        ? const Color(0xFFF9D6D3).withOpacity(0.83)
                        : const Color(0xFF6B73FF).withOpacity(0.83),
                  ),
                ),
              ),
            ),
            // Circle 2
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
                    color: isLeft 
                        ? const Color(0xFFFDBFC5).withOpacity(0.83)
                        : const Color(0xFF9B8CFF).withOpacity(0.83),
                  ),
                ),
              ),
            ),
            // Circle 3
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
                    color: isLeft 
                        ? const Color(0xFFFDC4A0).withOpacity(0.83)
                        : const Color(0xFF7C6BFF).withOpacity(0.83),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorldTiles(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Girl Meets College tile (left)
        _buildWorldTile(
          context,
          worldId: 'girl-meets-college',
          title: 'Girl Meets College',
          isLeft: true,
          stickerAsset: 'assets/sticker_image.png',
        ),
        // Guy Meets College tile (right)
        _buildWorldTile(
          context,
          worldId: 'guy-meets-college', 
          title: 'Guy Meets College',
          isLeft: false,
          stickerAsset: 'assets/Boy_sticker.png',
        ),
        // Tap indicators
        _buildTapIndicators(context),
      ],
    );
  }

  Widget _buildWorldTile(BuildContext context, {
    required String worldId,
    required String title,
    required bool isLeft,
    required String stickerAsset,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final boxWidth = 122.0;
    final boxHeight = 126.0;
    
    // Position on left or right side
    final leftOffset = isLeft 
        ? (screenSize.width / 4) - (boxWidth / 2)
        : (3 * screenSize.width / 4) - (boxWidth / 2);
    
    return Stack(
      children: [
        // Box
        Positioned(
          left: leftOffset,
          top: (screenSize.height - boxHeight) / 2,
          child: GestureDetector(
            onTap: () => _onWorldTileTap(worldId),
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
          ),
        ),
        // Sticker image
        Positioned(
          left: leftOffset - 80,
          top: (screenSize.height / 2) - 55,
          child: GestureDetector(
            onTap: () => _onWorldTileTap(worldId),
            child: Image.asset(
              stickerAsset,
              width: 165.29,
              height: 113.53,
              fit: BoxFit.contain,
            ),
          ),
        ),
        // Title
        Positioned(
          left: leftOffset - (boxWidth / 2),
          right: screenSize.width - leftOffset - (boxWidth * 1.5),
          top: (screenSize.height / 2) + (boxHeight / 2) + 15,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'SF Pro Rounded',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Color(0xFFB2B2B2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTapIndicators(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Left tap indicator
        Positioned(
          left: (screenSize.width / 4) - 20,
          top: (screenSize.height / 2) - 200,
          child: Image.asset(
            'assets/tap.png',
            width: 98,
            height: 98,
            fit: BoxFit.contain,
          ),
        ),
        // Right tap indicator
        Positioned(
          left: (3 * screenSize.width / 4) + 10,
          top: (screenSize.height / 2) - 200,
          child: Image.asset(
            'assets/tap.png',
            width: 98,
            height: 98,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  void _onWorldTileTap(String worldId) async {
    final worldService = WorldService();
    final authService = AuthService();
    final world = worldService.getWorldById(worldId);
    
    if (world != null) {
      // Track world visit for returning users
      final anonId = await authService.getOrCreateAnonId();
      await authService.trackWorldVisit(anonId, worldId);
      
      // Navigate to the actual game experience
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameExperienceScreen(
            selectedFloor: widget.selectedFloor,
            worldConfig: null,
          ),
        ),
      );
    }
  }
}