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
                const SizedBox(height: 35),
                _buildTeaTopicSection(),
                const Spacer(),
                _buildVibeSection(),
                const SizedBox(height: 20),
                _buildBottomInput(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildLiveStreamElements(),
          _buildChatArea(),
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
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
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
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 21),
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
      ),
    );
  }

  Widget _buildLiveStreamElements() {
    return Positioned(
      top: 190,
      right: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // LIVE button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 252, 252, 0.54),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(83, 83, 83, 0.04),
                  offset: const Offset(1, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontFamily: 'SF Compact Rounded',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Colors.black,
                    letterSpacing: 1.65,
                  ),
                ),
                const SizedBox(width: 7),
                Container(
                  width: 16,
                  height: 15,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6262),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Viewer count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 252, 252, 0.54),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(83, 83, 83, 0.04),
                  offset: const Offset(1, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/ChatGPT Image Aug 27, 2025 at 06_48_31 AM 1.png',
                  width: 21,
                  height: 21,
                ),
                const SizedBox(width: 3),
                const Text(
                  '15',
                  style: TextStyle(
                    fontFamily: 'SF Pro Rounded',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Colors.black,
                    letterSpacing: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Stack(
      children: [
        // Main chat area
        Positioned(
          top: 180,
          left: 40,
          right: 40,
          child: Container(
            height: 324,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFD8D8D8),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60), // Space to move content down under LIVE button
                  // Example confession post
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NICKNAME: THATGIRL123',
                        style: TextStyle(
                          fontFamily: 'SF Compact Rounded',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black,
                          letterSpacing: 1.65,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'I called my crush pretending that i was his mom so that he would tell me where he is 😭',
                        style: TextStyle(
                          fontFamily: 'SF Compact Rounded',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Colors.black,
                          letterSpacing: 1.65,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'REACT: [SAMEE🤭] [DEAD☠] [W🤪]',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'SF Compact Rounded',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Color(0xFFB2B2B2),
                          letterSpacing: 1.65,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // Subtle divider
                  Container(
                    width: double.infinity,
                    height: 1,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDEDBD9),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Queue section
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          '[ Upcoming Turns Queue ]',
                          style: TextStyle(
                            fontFamily: 'SF Pro Rounded',
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            color: Color(0xFFABABAB),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 280,
                          child: const Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              Text(
                                'THATGIRL123',
                                style: TextStyle(
                                  fontFamily: 'SF Compact Rounded',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Color(0xFFFF6262),
                                ),
                              ),
                              Text(
                                '→Who IS ShE',
                                style: TextStyle(
                                  fontFamily: 'SF Compact Rounded',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Color(0xFFABABAB),
                                ),
                              ),
                              Text(
                                '→Girlly',
                                style: TextStyle(
                                  fontFamily: 'SF Compact Rounded',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Color(0xFFABABAB),
                                ),
                              ),
                              Text(
                                '→316 girlly',
                                style: TextStyle(
                                  fontFamily: 'SF Compact Rounded',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Color(0xFFABABAB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Sketch lines - left side
        Positioned(
          top: 160,
          left: 10,
          child: CustomPaint(
            size: const Size(28.29, 20.24),
            painter: SketchLinesPainter1(),
          ),
        ),
        // Timer button - left of comment section
        Positioned(
          top: 190,
          left: 50,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 252, 252, 0.54),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(83, 83, 83, 0.04),
                  offset: const Offset(1, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Text(
              '11:43',
              style: TextStyle(
                fontFamily: 'SF Compact Rounded',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Colors.black,
                letterSpacing: 1.65,
              ),
            ),
          ),
        ),
        // Sketch lines - right side bottom
        Positioned(
          top: 500,
          right: 5,
          child: CustomPaint(
            size: const Size(42, 61.24),
            painter: SketchLinesPainter2(),
          ),
        ),
      ],
    );
  }
}

class SketchLinesPainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    // First line
    canvas.drawLine(
      const Offset(21, 0),
      const Offset(28.29, 15.24),
      paint,
    );
    
    // Second line
    canvas.drawLine(
      const Offset(0, 4),
      const Offset(23.29, 20.24),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SketchLinesPainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    // First line
    canvas.drawLine(
      const Offset(0, 9),
      const Offset(21.29, 61.24),
      paint,
    );
    
    // Second line
    canvas.drawLine(
      const Offset(7, 4),
      const Offset(15, 13),
      paint,
    );
    
    // Third line
    canvas.drawLine(
      const Offset(11, 0),
      const Offset(42, 9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}