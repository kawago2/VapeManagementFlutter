import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../models/vape_component.dart';
import '../models/component_health.dart';

class ComponentCard extends StatelessWidget {
  final VapeComponent component;
  final VoidCallback onQuickReset;

  const ComponentCard({
    super.key,
    required this.component,
    required this.onQuickReset,
  });

  Color _getStatusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.good:
        return const Color(0xFF10B981); // Emerald Green
      case HealthStatus.warning:
        return const Color(0xFFF59E0B); // Amber
      case HealthStatus.danger:
        return const Color(0xFFEF4444); // Rose Red
    }
  }

  Color _getStatusBg(HealthStatus status) {
    switch (status) {
      case HealthStatus.good:
        return const Color(0xFF064E3B).withValues(alpha: 0.35);
      case HealthStatus.warning:
        return const Color(0xFF78350F).withValues(alpha: 0.35);
      case HealthStatus.danger:
        return const Color(0xFF7F1D1D).withValues(alpha: 0.35);
    }
  }

  @override
  Widget build(BuildContext context) {
    final health = component.calculateHealth();
    final statusColor = _getStatusColor(health.status);
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2430),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header: Icon + Title + Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  component.icon,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      component.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBg(health.status),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  health.statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Days counter & progress label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${health.daysUsed}',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${health.maxDays} Hari',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Terakhir: ${dateFormat.format(component.lastServicedDate)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar Indicator
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 8.0,
            percent: health.ratio,
            backgroundColor: const Color(0xFF2C3545),
            progressColor: statusColor,
            barRadius: const Radius.circular(6),
            animation: true,
            animationDuration: 800,
          ),

          if (component.canQuickReset) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: onQuickReset,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Baru Diganti Hari Ini',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF252D3D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
