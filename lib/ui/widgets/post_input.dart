import 'package:flutter/material.dart';
import '../../view_models/post_input_view_model.dart';

class PostInput extends StatefulWidget {
  final VoidCallback? onPostSubmitted;
  
  const PostInput({super.key, this.onPostSubmitted});

  @override
  State<PostInput> createState() => _PostInputState();
}

class _PostInputState extends State<PostInput> {
  final TextEditingController _controller = TextEditingController();
  late PostInputViewModel _viewModel;
  String _selectedGender = 'girl';
  int _selectedFloor = 1;

  @override
  void initState() {
    super.initState();
    _viewModel = PostInputViewModel();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    setState(() {});
    
    if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      _viewModel.clearError();
    }
  }

  void _onPostPressed() async {
    await _viewModel.submitPost(
      _controller.text,
      _selectedFloor,
      _selectedGender,
      () {
        _controller.clear();
        if (widget.onPostSubmitted != null) {
          widget.onPostSubmitted!();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive dimensions
    final horizontalPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : screenWidth * 0.05);
    final verticalPadding = isDesktop ? 20.0 : (isTablet ? 18.0 : screenHeight * 0.015);
    final containerHeight = isDesktop ? 120.0 : (isTablet ? 110.0 : (screenHeight * 0.12).clamp(90.0, 110.0));
    
    // Text input area dimensions
    final inputLeftPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : screenWidth * 0.05);
    final inputTopPadding = isDesktop ? 20.0 : (isTablet ? 18.0 : screenHeight * 0.015);
    final inputBottomPadding = isDesktop ? 20.0 : (isTablet ? 18.0 : screenHeight * 0.015);
    
    // Post button dimensions
    final buttonWidth = isDesktop ? 80.0 : (isTablet ? 70.0 : (screenWidth * 0.15).clamp(55.0, 65.0));
    final buttonHeight = isDesktop ? 40.0 : (isTablet ? 36.0 : (screenHeight * 0.038).clamp(30.0, 35.0));
    final buttonRightPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : screenWidth * 0.03);
    
    // Font sizes
    final fontSize = isDesktop ? 14.0 : (isTablet ? 13.0 : (screenWidth * 0.033).clamp(12.0, 14.0));

    return Container(
      margin: const EdgeInsets.all(0),
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: verticalPadding * 0.5, // Reduced top padding
        bottom: verticalPadding,
      ),
      decoration: const BoxDecoration(),
      child: Container(
        height: containerHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFF1EDEA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFB2B2B2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Text input area
            Positioned(
              left: inputLeftPadding,
              top: inputTopPadding,
              right: buttonWidth + buttonRightPadding + 10, // Leave space for post button with padding
              bottom: inputBottomPadding,
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Type your confessions here.....',
                  hintStyle: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFB2B2B2),
                    letterSpacing: 0.4,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  letterSpacing: 0.4,
                  height: 1.3,
                ),
              ),
            ),
            
            // Post button
            Positioned(
              right: buttonRightPadding,
              bottom: inputBottomPadding,
              child: GestureDetector(
                onTap: _onPostPressed,
                child: Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
_viewModel.isSubmitting ? 'Posting...' : 'Post',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: fontSize,
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
    );
  }
}