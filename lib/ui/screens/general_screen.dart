import 'package:flutter/material.dart';
import 'dart:ui';
import 'game_experience_screen.dart';
import '../../services/auth/auth_service.dart';
import '../../services/core/world_service.dart';
import '../../services/data/local_storage_service.dart';
import '../../services/simulation/bot_assignment_service.dart';
import '../../services/admin/simple_admin_service.dart';
import '../../config/world_config.dart';
import '../widgets/forms/world_access_modal.dart';

void main() => runApp(MaterialApp(home: GeneralScreen()));

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({super.key});

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  final WorldService _worldService = WorldService();
  late List<WorldConfig> _availableWorlds;

  @override
  void initState() {
    super.initState();
    _availableWorlds = _worldService.getAllWorlds();
  }

  Future<void> _checkAuthAndNavigate(BuildContext context, WorldConfig world) async {

    final authService = AuthService();
    final localStorageService = LocalStorageService();
    final simpleAdminService = SimpleAdminService();

    // Store the selected world
    await localStorageService.setWorld(world.displayName);

    // Check if user is authenticated for this specific world
    final isLoggedInForWorld = await authService.isLoggedInForWorld(world.id);

    if (isLoggedInForWorld) {
      // This is a RETURNING user with existing account
      // Check admin settings - if returning users are blocked, show message
      final areReturningUsersAllowed = await simpleAdminService.areReturningUsersAllowed();

      if (!areReturningUsersAllowed) {
        // Show blocked message for returning users
        if (context.mounted) {
          _showBlockedMessage(context);
        }
        return;
      }

      // Track world visit for returning users
      final anonId = await authService.getOrCreateAnonId();
      await authService.trackWorldVisit(anonId, world.id);

      // User has account for this world, navigate directly
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameExperienceScreen(
              selectedFloor: 1,
              worldConfig: world,
            ),
          ),
        );
      }
    } else {
      // This is a NEW user without existing account
      // New users can always go through the signup process regardless of admin toggle
      // (The admin toggle only blocks existing users from re-entering)

      // User needs to create account for this world, show modal
      if (context.mounted) {
        _showWorldAccessModal(context, world);
      }
    }
  }

  void _showBlockedMessage(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width > 400 ? 350 : MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFFF1EDEA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFB2B2B2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Color(0xFFEF4444),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'come back tomorrow ✨',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'the worlds are currently closed for new experiences. check back tomorrow for the next adventure!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'got it',
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
          ),
        ),
      ),
    );
  }

  void _showWorldAccessModal(BuildContext context, WorldConfig world) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WorldAccessModal(
        worldConfig: world,
        onSubmit: (accessCode, nickname, vibeAnswers) async {
          final authService = AuthService();
          final success = await authService.createAccountForWorld(accessCode, nickname, world.id);

          if (success) {
            // Assign bots based on vibe check
            final botAssignmentService = BotAssignmentService();
            await botAssignmentService.assignBotsBasedOnVibeCheck(vibeAnswers);
          }
          
          if (success && context.mounted) {
            Navigator.of(context).pop(); // Close modal
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameExperienceScreen(
                  selectedFloor: 1,
                  worldConfig: world,
                ),
              ),
            );
          } else {
            // Throw error to trigger inline validation error in modal
            throw Exception('Invalid access code');
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
          _buildBackgroundCollages(context),
          _buildWorldTiles(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundCollages(BuildContext context) {
    return Stack(
      children: [
        // Girl Meets College background (centered)
        _buildFadeBackground(context, isLeft: true),
        // Guy Meets College background (right side) - COMMENTED OUT
        // _buildFadeBackground(context, isLeft: false),
      ],
    );
  }

  Widget _buildFadeBackground(BuildContext context, {required bool isLeft}) {
    final screenSize = MediaQuery.of(context).size;
    final groupWidth = 124.0;
    final groupHeight = 128.0;
    
    // Position: center the background since we only have Girl Meets College
    final leftOffset = (screenSize.width / 2) - (groupWidth / 2);
    
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
                        : const Color(0xFF6B73FF).withOpacity(0.4),
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
                        : const Color(0xFF9B8CFF).withOpacity(0.4),
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
                        : const Color(0xFF7C6BFF).withOpacity(0.4),
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
    final girlWorld = _availableWorlds.firstWhere((world) => world.id == 'girl-meets-college');
    // final guyWorld = _availableWorlds.firstWhere((world) => world.id == 'guy-meets-college');

    return Stack(
      children: [
        // Girl Meets College tile (centered)
        _buildWorldTile(
          context,
          world: girlWorld,
          isLeft: false, // Changed to false to center it
          stickerAsset: 'assets/sticker_image.png',
        ),
        // Guy Meets College tile (right) - COMMENTED OUT
        // _buildWorldTile(
        //   context,
        //   world: guyWorld,
        //   isLeft: false,
        //   stickerAsset: 'assets/Boy_sticker.png',
        // ),
        // Tap indicators - COMMENTED OUT
        // _buildTapIndicators(context),
      ],
    );
  }

  Widget _buildWorldTile(BuildContext context, {
    required WorldConfig world,
    required bool isLeft,
    required String stickerAsset,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final boxWidth = 122.0;
    final boxHeight = 126.0;
    
    // Position: left side, right side, or centered
    final leftOffset = isLeft
        ? (screenSize.width / 2 - 100) - (boxWidth / 2)  // Left position
        : (screenSize.width / 2) - (boxWidth / 2);        // Centered position
    
    return Stack(
      children: [
        // Box
        Positioned(
          left: leftOffset,
          top: (screenSize.height - boxHeight) / 2,
          child: GestureDetector(
            onTap: () => _checkAuthAndNavigate(context, world),
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
        // Sticker image - centered on the box
        Positioned(
          left: leftOffset + (boxWidth / 2) - (stickerAsset.contains('Boy_sticker') ? 140.0 / 2 : 165.29 / 2),
          top: (screenSize.height / 2) - (126.0 / 2) + (boxHeight / 2) - (stickerAsset.contains('Boy_sticker') ? 96.0 / 2 : 113.53 / 2),
          child: GestureDetector(
            onTap: () => _checkAuthAndNavigate(context, world),
            child: Image.asset(
              stickerAsset,
              width: stickerAsset.contains('Boy_sticker') ? 140.0 : 165.29,
              height: stickerAsset.contains('Boy_sticker') ? 96.0 : 113.53,
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
              world.displayName,
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
        // Only show tap indicator for Guy Meets College (right side)
        Positioned(
          left: (screenSize.width / 2 + 100) + 10,
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

}