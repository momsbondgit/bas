import 'package:flutter/material.dart';
import 'dart:ui';

void main() => runApp(MaterialApp(home: GirlMeetsWorldScreen()));

class GirlMeetsWorldScreen extends StatelessWidget {
  const GirlMeetsWorldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF9),
      body: Stack(
        children: [
          _buildFadeBackground(context),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                _buildTitle(),
                const SizedBox(height: 10),
                _buildTimer(),
                const SizedBox(height: 40),
                _buildTeaTopicSection(),
                const Spacer(),
                _buildVibeSection(),
                const SizedBox(height: 20),
                _buildBottomInput(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFadeBackground(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final backgroundWidth = 531.0;
    final backgroundHeight = 504.0;
    
    return Positioned(
      left: (screenSize.width - backgroundWidth) / 2,
      top: (screenSize.height - backgroundHeight) / 2,
      child: SizedBox(
        width: backgroundWidth,
        height: backgroundHeight,
        child: Stack(
          children: [
            Positioned(
              left: 125,
              top: 0,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 114.6, sigmaY: 114.6),
                child: Container(
                  width: 250,
                  height: 270,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(250, 186, 196, 0.5),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 226,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 114.6, sigmaY: 114.6),
                child: Container(
                  width: 220,
                  height: 230,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(254, 205, 160, 0.5),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 267,
              top: 202,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 114.6, sigmaY: 114.6),
                child: Container(
                  width: 215,
                  height: 230,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(251, 222, 216, 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Girl meets college 💅🌎',
      style: TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontWeight: FontWeight.w500,
        fontSize: 24,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTimer() {
    return const Text(
      'Timer: 11:43 remaining',
      style: TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTeaTopicSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Tea topic of the day:',
            style: TextStyle(
              fontFamily: 'SF Pro Rounded',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF484848),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "What's the cringiest thing you've done to get a cute guys attention😩",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Crafty Girls',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.black,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVibeSection() {
    return Container(
      width: double.infinity,
      child: const Padding(
        padding: EdgeInsets.only(left: 40, right: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'The Vibe',
            style: TextStyle(
              fontFamily: 'SF Compact Rounded',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFFABABAB),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '1. One at a time -- wait your turn.\n2. Don\'t hole back girl, drop the tea.\n3. React to everyone -- show your at the table.',
            style: TextStyle(
              fontFamily: 'SF Compact Rounded',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFFABABAB),
              height: 1.2,
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        height: 47,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(37),
        ),
        child: const Center(
          child: Text(
            'We know that you have cringing moments too...',
            style: TextStyle(
              fontFamily: 'SF Pro Rounded',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: Color(0xFF8F8F8F),
            ),
          ),
        ),
      ),
    );
  }
}