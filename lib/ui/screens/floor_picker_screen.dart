import 'package:flutter/material.dart';
import '../widgets/floor_button.dart';
import 'home_screen.dart';
import '../../services/local_storage_service.dart';

class FloorPickerScreen extends StatefulWidget {
  const FloorPickerScreen({super.key});

  @override
  State<FloorPickerScreen> createState() => _FloorPickerScreenState();
}

class _FloorPickerScreenState extends State<FloorPickerScreen> {
  int? selectedFloor;
  String? selectedGender;

  void onFloorSelected(int floor) {
    setState(() {
      selectedFloor = floor;
    });
  }

  void onGenderSelected(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  void onReadyPressed() async {
    if (selectedFloor != null && selectedGender != null) {
      print('DEBUG: FloorPicker saving floor: $selectedFloor, gender: $selectedGender');
      final localStorageService = LocalStorageService();
      await localStorageService.setFloor(selectedFloor!);
      await localStorageService.setGender(selectedGender!);
      
      // Verify it was saved
      final savedFloor = await localStorageService.getFloor();
      final savedGender = await localStorageService.getGender();
      print('DEBUG: FloorPicker verified saved floor: $savedFloor, gender: $savedGender');
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomeScreen(selectedFloor: selectedFloor!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // Responsive padding (15% of screen width, min 24, max 54)
    final horizontalPadding = (screenWidth * 0.15).clamp(24.0, 54.0);
    
    // Responsive font sizes
    final headerFontSize = (screenWidth * 0.05).clamp(16.0, 22.0);
    final titleFontSize = (screenWidth * 0.06).clamp(20.0, 26.0);
    final buttonFontSize = (screenWidth * 0.04).clamp(14.0, 18.0);
    final subtextFontSize = (screenWidth * 0.02).clamp(16.0, 22.0);
    
    // Responsive button dimensions
    final buttonWidth = (screenWidth * 0.32).clamp(120.0, 150.0);
    final buttonHeight = (screenHeight * 0.055).clamp(40.0, 50.0);
    final buttonGap = screenWidth * 0.02;
    
    // Responsive spacing
    final topSpacing = screenHeight * 0.08;
    final sectionSpacing = screenHeight * 0.06;
    final bottomPadding = screenHeight * 0.05;

    return Scaffold(
      backgroundColor: const Color(0xFFF1EDEA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: topSpacing),
                  
                  // Header text with emojis - with hidden admin access
                  GestureDetector(
                    onTap: () {
                      // Hidden admin access - triple tap to access admin
                    },
                    onLongPress: () {
                      Navigator.of(context).pushNamed('/admin');
                    },
                    child: Text(
                      'IF YOU SNITCH YOUR A OPP\n🤬🫵',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        letterSpacing: headerFontSize * 0.11,
                        height: 1.2,
                      ),
                    ),
                  ),

                  Text(
                    'Lions Gate Secrets',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: subtextFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      letterSpacing: headerFontSize * 0.11,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: sectionSpacing),
                  
                  // Pick your floor section
                  Column(
                    children: [
                      Text(
                        'PICK YOUR FLOOR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SF Compact Rounded',
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFB2B2B2),
                          letterSpacing: titleFontSize * 0.11,
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.02),
                      
                      // Floor buttons grid - centered, 2x2 layout
                      Column(
                        children: [
                          // First row: Floor 1 and Floor 2
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => onFloorSelected(1),
                                child: Container(
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selectedFloor == 1 ? Colors.black : const Color(0xFFB2B2B2),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: selectedFloor == 1 ? Colors.black : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'FLOOR 1',
                                      style: TextStyle(
                                        fontFamily: 'SF Pro',
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.w400,
                                        color: selectedFloor == 1 ? Colors.white : const Color(0xFFB2B2B2),
                                        letterSpacing: buttonFontSize * 0.11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: buttonGap),
                              GestureDetector(
                                onTap: () => onFloorSelected(2),
                                child: Container(
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selectedFloor == 2 ? Colors.black : const Color(0xFFB2B2B2),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: selectedFloor == 2 ? Colors.black : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'FLOOR 2',
                                      style: TextStyle(
                                        fontFamily: 'SF Pro',
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.w400,
                                        color: selectedFloor == 2 ? Colors.white : const Color(0xFFB2B2B2),
                                        letterSpacing: buttonFontSize * 0.11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: buttonGap),
                          
                          // Second row: Floor 3 and Floor 4
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => onFloorSelected(3),
                                child: Container(
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selectedFloor == 3 ? Colors.black : const Color(0xFFB2B2B2),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: selectedFloor == 3 ? Colors.black : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'FLOOR 3',
                                      style: TextStyle(
                                        fontFamily: 'SF Pro',
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.w400,
                                        color: selectedFloor == 3 ? Colors.white : const Color(0xFFB2B2B2),
                                        letterSpacing: buttonFontSize * 0.11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: buttonGap),
                              GestureDetector(
                                onTap: () => onFloorSelected(4),
                                child: Container(
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selectedFloor == 4 ? Colors.black : const Color(0xFFB2B2B2),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: selectedFloor == 4 ? Colors.black : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'FLOOR 4',
                                      style: TextStyle(
                                        fontFamily: 'SF Pro',
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.w400,
                                        color: selectedFloor == 4 ? Colors.white : const Color(0xFFB2B2B2),
                                        letterSpacing: buttonFontSize * 0.11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.06),
                  
                  // Gender selection section
                  Column(
                    children: [
                      Text(
                        'SELECT GENDER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SF Compact Rounded',
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFB2B2B2),
                          letterSpacing: titleFontSize * 0.11,
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.02),
                      
                      // Gender buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => onGenderSelected('Boy'),
                            child: Container(
                              width: buttonWidth,
                              height: buttonHeight,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedGender == 'Boy' ? Colors.black : const Color(0xFFB2B2B2),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: selectedGender == 'Boy' ? Colors.black : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  'BOY',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.w400,
                                    color: selectedGender == 'Boy' ? Colors.white : const Color(0xFFB2B2B2),
                                    letterSpacing: buttonFontSize * 0.11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: buttonGap),
                          GestureDetector(
                            onTap: () => onGenderSelected('Girl'),
                            child: Container(
                              width: buttonWidth,
                              height: buttonHeight,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedGender == 'Girl' ? Colors.black : const Color(0xFFB2B2B2),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: selectedGender == 'Girl' ? Colors.black : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  'GIRL',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.w400,
                                    color: selectedGender == 'Girl' ? Colors.white : const Color(0xFFB2B2B2),
                                    letterSpacing: buttonFontSize * 0.11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.08),
                  
                  // Ready button
                  Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: GestureDetector(
                      onTap: onReadyPressed,
                      child: Container(
                        width: (screenWidth * 0.65).clamp(200.0, 280.0),
                        height: (screenHeight * 0.065).clamp(48.0, 60.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: (selectedFloor != null && selectedGender != null) ? Colors.black : const Color(0xFFB2B2B2),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: (selectedFloor != null && selectedGender != null) ? Colors.black : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            'READY FOR THE TEA 🤪',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.w400,
                              color: (selectedFloor != null && selectedGender != null) ? Colors.white : const Color(0xFFB2B2B2),
                              letterSpacing: buttonFontSize * 0.11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}