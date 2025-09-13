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
  // Removed gender selection - now uses world-based posting
  int _selectedFloor = 1;
  bool _preferencesLoaded = false;

  @override
  void initState() {
    super.initState();
    _viewModel = PostInputViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _loadUserPreferences();
  }

  void _loadUserPreferences() async {
    try {
      // Add a small delay to ensure LocalStorage write has completed
      await Future.delayed(const Duration(milliseconds: 100));
      
      final preferences = await _viewModel.loadUserPreferences();
      
      if (mounted) {
        setState(() {
          _selectedFloor = preferences['floor'];
          _preferencesLoaded = true;
        });
      }
      
      // Retry mechanism if we got default values (indicating possible race condition)
      if (preferences['floor'] == 1) {
        await Future.delayed(const Duration(milliseconds: 500));
        final retryPreferences = await _viewModel.loadUserPreferences();
        
        if (mounted) {
          setState(() {
            _selectedFloor = retryPreferences['floor'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _preferencesLoaded = true; // Still mark as loaded to avoid blocking UI
        });
      }
    }
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
    // Don't allow posting until preferences are loaded
    if (!_preferencesLoaded) {
      return;
    }
    await _viewModel.submitPost(
      _controller.text,
      _selectedFloor,
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
    
    // Fixed minimal dimensions to match waiting state
    final horizontalPadding = 16.0; // Fixed padding
    final verticalPadding = 8.0; // Minimal padding
    final containerHeight = 60.0; // Fixed height to match waiting state exactly
    
    // Text input area dimensions - fixed to match waiting state
    final inputLeftPadding = 16.0;
    final inputTopPadding = 12.0;
    final inputBottomPadding = 12.0;
    
    // Post button dimensions - fixed to fit within waiting state height
    final buttonWidth = 60.0;
    final buttonHeight = 32.0;
    final buttonRightPadding = 12.0;
    
    // Font sizes - fixed to match waiting state
    final fontSize = 14.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.all(0),
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            top: verticalPadding, // Minimal top padding
            bottom: verticalPadding,
          ),
          child: Builder(
            builder: (context) {
              return Container(
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
              bottom: inputBottomPadding, // No extra space needed
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                maxLength: 200, // Character limit to prevent scrolling
                buildCounter: (context, {currentLength, isFocused, maxLength}) {
                  // Hide counter to match waiting state size exactly
                  return const SizedBox.shrink();
                },
                decoration: InputDecoration(
                  hintText: 'Type your confessions here..... (max 200 characters)',
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
              );
            },
          ),
        );
      },
    );
  }
}