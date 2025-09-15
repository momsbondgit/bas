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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Compass Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : _loadMetrics,
                child: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_metricsList != null && _metricsList!.users.isNotEmpty)
            _buildUserMetricsList()
          else
            const Text('No user data available'),
        ],
      ),
    );
  }

  Widget _buildUserMetricsList() {
    return Column(
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Row(
            children: [
              Expanded(flex: 2, child: Text('User', style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(child: Text('North', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(child: Text('East', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(child: Text('South', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(child: Text('West', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // User rows
        ...(_metricsList!.users.map((user) => _buildUserRow(user))),
      ],
    );
  }

  Widget _buildUserRow(UserCompassMetrics user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // User info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname ?? 'Anonymous',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  user.userId.substring(0, 8),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          // North - Belonging
          Expanded(
            child: _buildCompassValue(
              user.hasReturned ? '✓' : '○',
              user.hasReturned ? Colors.green : Colors.grey,
            ),
          ),
          // East - Flow
          Expanded(
            child: _buildCompassValue(
              '${user.sessionsCompleted}/${user.totalSessions}',
              user.sessionsCompleted > 0 ? Colors.green : Colors.grey,
            ),
          ),
          // South - Voice
          Expanded(
            child: _buildCompassValue(
              '${user.postsCreated}',
              user.postsCreated > 0 ? Colors.green : Colors.grey,
            ),
          ),
          // West - Affection
          Expanded(
            child: _buildCompassValue(
              '~${user.reactionsGiven}',
              user.reactionsGiven > 0 ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassValue(String value, Color color) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }
}