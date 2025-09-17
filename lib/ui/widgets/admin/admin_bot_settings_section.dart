import 'package:flutter/material.dart';
import '../../../services/admin/bot_settings_service.dart';
import '../../../models/user/bot_user.dart';

class AdminBotSettingsSection extends StatefulWidget {
  const AdminBotSettingsSection({super.key});

  @override
  State<AdminBotSettingsSection> createState() => _AdminBotSettingsSectionState();
}

class _AdminBotSettingsSectionState extends State<AdminBotSettingsSection> {
  final BotSettingsService _botSettingsService = BotSettingsService();
  final Map<String, TextEditingController> _nicknameControllers = {};
  final Map<String, TextEditingController> _responseControllers = {};
  final Map<String, TextEditingController> _goodbyeControllers = {};
  final Map<String, bool> _editingStates = {};

  @override
  void dispose() {
    for (final controller in _nicknameControllers.values) {
      controller.dispose();
    }
    for (final controller in _responseControllers.values) {
      controller.dispose();
    }
    for (final controller in _goodbyeControllers.values) {
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
                  Icons.smart_toy,
                  color: Color(0xFF8B5CF6),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Bot Settings - Girl World',
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
            'Edit bot nicknames, responses, and goodbye messages',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          _buildBotTable('Table 1 - Chaotic/Edgy', 1),
          const SizedBox(height: 24),
          _buildBotTable('Table 2 - Goofy/Soft', 2),
        ],
      ),
    );
  }

  Widget _buildBotTable(String title, int tableNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<BotUser>>(
          stream: _botSettingsService.getBotStream('girl-meets-college', tableNumber),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return FutureBuilder<List<BotUser>>(
                future: _botSettingsService.getBots('girl-meets-college', tableNumber),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final bots = futureSnapshot.data ?? [];
                  return Column(
                    children: bots.map((bot) => _buildBotCard(bot, tableNumber)).toList(),
                  );
                },
              );
            }

            final bots = snapshot.data!;
            return Column(
              children: bots.map((bot) => _buildBotCard(bot, tableNumber)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBotCard(BotUser bot, int tableNumber) {
    final key = '${bot.botId}_$tableNumber';
    final isEditing = _editingStates[key] ?? false;

    if (!_nicknameControllers.containsKey(key)) {
      _nicknameControllers[key] = TextEditingController(text: bot.nickname);
      _responseControllers[key] = TextEditingController(text: bot.quineResponse);
      _goodbyeControllers[key] = TextEditingController(text: bot.goodbyeText);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  'Bot ID: ${bot.botId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(isEditing ? Icons.save : Icons.edit),
                iconSize: 18,
                onPressed: () async {
                  // Preserve scroll position
                  final scrollController = Scrollable.of(context).position;
                  final currentOffset = scrollController.pixels;

                  if (isEditing) {
                    final updatedBot = BotUser(
                      botId: bot.botId,
                      nickname: _nicknameControllers[key]!.text,
                      quineResponse: _responseControllers[key]!.text,
                      goodbyeText: _goodbyeControllers[key]!.text,
                    );
                    await _botSettingsService.updateBot(
                      'girl-meets-college',
                      tableNumber,
                      updatedBot,
                    );
                    setState(() {
                      _editingStates[key] = false;
                    });
                    // Restore scroll position after rebuild
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (scrollController.hasPixels) {
                        scrollController.jumpTo(currentOffset);
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bot updated successfully')),
                    );
                  } else {
                    setState(() {
                      _editingStates[key] = true;
                    });
                    // Restore scroll position after rebuild
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (scrollController.hasPixels) {
                        scrollController.jumpTo(currentOffset);
                      }
                    });
                  }
                },
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.cancel),
                  iconSize: 18,
                  onPressed: () {
                    // Preserve scroll position
                    final scrollController = Scrollable.of(context).position;
                    final currentOffset = scrollController.pixels;

                    _nicknameControllers[key]!.text = bot.nickname;
                    _responseControllers[key]!.text = bot.quineResponse;
                    _goodbyeControllers[key]!.text = bot.goodbyeText;
                    setState(() {
                      _editingStates[key] = false;
                    });
                    // Restore scroll position after rebuild
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (scrollController.hasPixels) {
                        scrollController.jumpTo(currentOffset);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildField('Nickname', _nicknameControllers[key]!, isEditing),
          const SizedBox(height: 8),
          _buildField('Response', _responseControllers[key]!, isEditing, maxLines: 2),
          const SizedBox(height: 8),
          _buildField('Goodbye', _goodbyeControllers[key]!, isEditing, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool isEditing, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: isEditing,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
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
        ),
      ],
    );
  }
}