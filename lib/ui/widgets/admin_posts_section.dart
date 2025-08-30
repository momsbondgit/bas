import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/post_service.dart';

class AdminPostsSection extends StatefulWidget {
  final List<QueryDocumentSnapshot> posts;
  final VoidCallback onPostDeleted;

  const AdminPostsSection({
    super.key,
    required this.posts,
    required this.onPostDeleted,
  });

  @override
  State<AdminPostsSection> createState() => _AdminPostsSectionState();
}

class _AdminPostsSectionState extends State<AdminPostsSection> {
  final PostService _postService = PostService();
  String? _editingPostId;
  final TextEditingController _editController = TextEditingController();

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.article,
                    color: Color(0xFF6366F1),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Posts Management',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.15)),
                  ),
                  child: Text(
                    '${widget.posts.length} posts',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Posts List
          Expanded(
            child: widget.posts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 48,
                          color: Color(0xFF9CA3AF),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          'Posts will appear here when users submit them',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.posts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final post = widget.posts[index];
                      final data = post.data() as Map<String, dynamic>;
                      final isEditing = _editingPostId == post.id;
                      
                      return _buildPostCard(post, data, isEditing);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(QueryDocumentSnapshot post, Map<String, dynamic> data, bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Row(
            children: [
              // Floor and gender info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Floor ${data['floor']}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data['gender'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
              const Spacer(),
              if (!isEditing) ...[
                IconButton(
                  onPressed: () => _startEditing(post.id, data['text'] ?? ''),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1).withOpacity(0.08),
                    foregroundColor: const Color(0xFF6366F1),
                    minimumSize: const Size(36, 36),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _deletePost(post.id),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444).withOpacity(0.08),
                    foregroundColor: const Color(0xFFEF4444),
                    minimumSize: const Size(36, 36),
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Post content
          if (isEditing) ...[
            TextField(
              controller: _editController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Edit post content...',
                hintStyle: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _saveEdit(post.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _cancelEditing,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              data['text'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // Reactions
            if (data['reactions'] != null) ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (data['reactions'] as Map<String, dynamic>).entries
                    .map((entry) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.key} ${entry.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _startEditing(String postId, String currentText) {
    setState(() {
      _editingPostId = postId;
      _editController.text = currentText;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingPostId = null;
      _editController.clear();
    });
  }

  void _saveEdit(String postId) async {
    try {
      await _postService.editPost(postId, _editController.text.trim());
      widget.onPostDeleted(); // Refresh
      _cancelEditing();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Post updated successfully',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating post: $e',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  void _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete Post',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _postService.deletePost(postId);
        widget.onPostDeleted();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Post deleted successfully',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error deleting post: $e',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    }
  }
}