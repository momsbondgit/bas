import 'package:flutter/material.dart';

class FloorButton extends StatelessWidget {
  final int floorNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const FloorButton({
    super.key,
    required this.floorNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.04).clamp(14.0, 18.0);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFB2B2B2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? const Color(0xFFB2B2B2).withOpacity(0.1) : Colors.transparent,
        ),
        child: Center(
          child: Text(
            'Floor $floorNumber',
            style: TextStyle(
              fontFamily: 'SF Compact Rounded',
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.black : const Color(0xFFB2B2B2),
              letterSpacing: fontSize * 0.11,
            ),
          ),
        ),
      ),
    );
  }
}