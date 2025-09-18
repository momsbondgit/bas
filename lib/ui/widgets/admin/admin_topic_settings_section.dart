import 'package:flutter/material.dart';
import '../../../services/admin/topic_settings_service.dart';

class AdminTopicSettingsSection extends StatefulWidget {
  const AdminTopicSettingsSection({super.key});

  @override
  State<AdminTopicSettingsSection> createState() => _AdminTopicSettingsSectionState();
}

class _AdminTopicSettingsSectionState extends State<AdminTopicSettingsSection> {
  final TopicSettingsService _topicSettingsService = TopicSettingsService();
  final Map<String, TextEditingController> _topicControllers = {};
  final Map<String, bool> _editingStates = {};

  final List<Map<String, String>> _worlds = [
    {'id': 'girl-meets-college', 'name': 'Girl Meets College'},
  ];

  @override
  void dispose() {
    for (final controller in _topicControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.topic,
                  color: Color(0xFF8B5CF6),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Topic Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Edit topic of the day for each world',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          ..._worlds.map((world) => _buildWorldTopicEditor(world['id']!, world['name']!)),
        ],
      ),
    );
  }

  Widget _buildWorldTopicEditor(String worldId, String worldName) {
    final isEditing = _editingStates[worldId] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  worldName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(isEditing ? Icons.save : Icons.edit),
                iconSize: 18,
                onPressed: () async {
                  if (isEditing) {
                    final topic = _topicControllers[worldId]?.text ?? '';
                    await _topicSettingsService.updateTopic(worldId, topic);
                    setState(() {
                      _editingStates[worldId] = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Topic updated successfully')),
                    );
                  } else {
                    setState(() {
                      _editingStates[worldId] = true;
                    });
                  }
                },
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.cancel),
                  iconSize: 18,
                  onPressed: () {
                    setState(() {
                      _editingStates[worldId] = false;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<String?>(
            stream: _topicSettingsService.getTopicStream(worldId),
            builder: (context, snapshot) {
              final currentTopic = snapshot.data ?? '';

              if (!_topicControllers.containsKey(worldId)) {
                _topicControllers[worldId] = TextEditingController(text: currentTopic);
              } else if (!isEditing) {
                _topicControllers[worldId]!.text = currentTopic;
              }

              return TextField(
                controller: _topicControllers[worldId],
                enabled: isEditing,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter topic of the day...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: isEditing ? Colors.white : const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: isEditing ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}