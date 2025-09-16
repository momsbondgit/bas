import 'package:flutter/material.dart';
import '../../../models/metrics/compass_metrics.dart';
import '../../../services/metrics/metrics_service.dart';

class AdminMetricsSection extends StatefulWidget {
  const AdminMetricsSection({super.key});

  @override
  State<AdminMetricsSection> createState() => _AdminMetricsSectionState();
}

class _AdminMetricsSectionState extends State<AdminMetricsSection> {
  final MetricsService _metricsService = MetricsService();
  CompassMetricsList? _metricsList;
  bool _isLoading = false;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    try {
      final metrics = await _metricsService.getUserCompassMetrics();
      setState(() => _metricsList = metrics);
    } finally {
      setState(() => _isLoading = false);
    }
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
          _buildHeader(),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_metricsList != null && _metricsList!.users.isNotEmpty)
            _buildUserListView()
          else
            const Center(
              child: Text(
                'No real users found',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.explore,
                color: Color(0xFF6366F1),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Compass Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Real Users Only',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: _isLoading ? null : _loadMetrics,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Refresh'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
          ),
        ),
      ],
    );
  }

  Widget _buildUserListView() {
    return Column(
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Nickname',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'User ID',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // User rows
        ...(_metricsList!.users.map((user) => Column(
              children: [
                _buildUserRow(user),
                if (_selectedUserId == user.userId) _buildExpandedMetricsView(user),
              ],
            ))),
      ],
    );
  }

  Widget _buildUserRow(UserCompassMetrics user) {
    final isExpanded = _selectedUserId == user.userId;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedUserId = isExpanded ? null : user.userId;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isExpanded ? const Color(0xFF6366F1).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isExpanded ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            // Nickname
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.nickname ?? 'Anonymous',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // User ID (shortened)
            Expanded(
              child: Text(
                user.userId.substring(0, 8) + '...',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontFamily: 'monospace',
                ),
              ),
            ),
            // Status
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(user.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(user.status),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedMetricsView(UserCompassMetrics user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 24, right: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // North - Belonging Proof
          _buildCompassMetric(
            direction: 'North',
            directionColor: const Color(0xFF3B82F6),
            icon: Icons.people,
            title: 'Belonging Proof',
            question: 'Did they return? How many times?',
            metric: 'Number of returns per real user',
            indicator: user.returnCount > 0
                ? '✅ Returned ${user.returnCount}x'
                : '○ Not returned',
            indicatorColor: user.returnCount > 0 ? Colors.green : Colors.grey,
            meaning: 'Shows if users feel continuity — same table, same cast, not reshuffled.',
          ),
          const SizedBox(height: 20),

          // East - Flow Working
          _buildCompassMetric(
            direction: 'East',
            directionColor: const Color(0xFFF59E0B),
            icon: Icons.timeline,
            title: 'Flow Working',
            question: 'Did they complete the full session?',
            metric: 'Sessions completed vs total attempts',
            indicator: '${user.sessionsCompleted}/${user.totalSessions} sessions',
            indicatorColor: user.sessionsCompleted > 0 ? Colors.green : Colors.grey,
            meaning: 'Shows if users feel rhythm — start → middle → goodbye → "see you tomorrow."',
          ),
          const SizedBox(height: 20),

          // South - Voice / Recognition
          _buildCompassMetric(
            direction: 'South',
            directionColor: const Color(0xFF10B981),
            icon: Icons.mic,
            title: 'Voice / Recognition',
            question: 'Did they get their voice in?',
            metric: 'Posts per real user (should be ≥1)',
            indicator: user.postsCreated == 1
                ? '1 post'
                : '${user.postsCreated} posts',
            indicatorColor: user.postsCreated > 0 ? Colors.green : Colors.grey,
            meaning: 'Shows if users feel seen — they got their turn, their words landed.',
          ),
          const SizedBox(height: 20),

          // West - Affection / Resonance
          _buildCompassMetric(
            direction: 'West',
            directionColor: const Color(0xFFEF4444),
            icon: Icons.favorite,
            title: 'Affection / Resonance',
            question: 'Did they react emotionally?',
            metric: 'Total reactions made by real users',
            indicator: user.reactionsGiven == 1
                ? '1 reaction'
                : '${user.reactionsGiven} reactions',
            indicatorColor: user.reactionsGiven > 0 ? Colors.green : Colors.grey,
            meaning: 'Shows if users felt emotional response — laughter, empathy, or spice from the table.',
          ),
        ],
      ),
    );
  }

  Widget _buildCompassMetric({
    required String direction,
    required Color directionColor,
    required IconData icon,
    required String title,
    required String question,
    required String metric,
    required String indicator,
    required Color indicatorColor,
    required String meaning,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricHeader(direction, directionColor, icon, title),
          const SizedBox(height: 12),
          _buildMetricRow('Question: ', question, const Color(0xFFF3F4F6)),
          const SizedBox(height: 8),
          _buildSimpleMetricRow('Metric: ', metric),
          const SizedBox(height: 8),
          _buildIndicatorRow(indicator, indicatorColor),
          const SizedBox(height: 8),
          _buildMetricRow('Meaning: ', meaning, const Color(0xFFFEF3C7),
              labelColor: const Color(0xFFB45309), textColor: const Color(0xFF92400E)),
        ],
      ),
    );
  }

  Widget _buildMetricHeader(String direction, Color color, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(direction, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(width: 8),
        Text('— $title', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
      ],
    );
  }

  Widget _buildMetricRow(String label, String text, Color backgroundColor, {Color? labelColor, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: labelColor ?? const Color(0xFF6B7280))),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: textColor ?? const Color(0xFF374151)))),
        ],
      ),
    );
  }

  Widget _buildSimpleMetricRow(String label, String text) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF374151)))),
      ],
    );
  }

  Widget _buildIndicatorRow(String indicator, Color color) {
    return Row(
      children: [
        const Text('Indicator: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(indicator, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF3B82F6);
      case 'Returning':
        return const Color(0xFF10B981);
      case 'Completed':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }
}