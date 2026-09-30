import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vape_entities.dart';

class CompactBatteryRowView extends StatelessWidget {
  final BatteryItem battery;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CompactBatteryRowView({
    super.key,
    required this.battery,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final badgeBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final secondaryTextColor = const Color(0xFF8E8E93);

    final isOverdue = battery.healthStatus.isOverdue;
    final dateFormat = DateFormat('dd/MM/yy');

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                battery.code,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    battery.brandAndType,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                  ),
                  if (battery.notes.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      battery.notes,
                      style: TextStyle(
                        fontSize: 10,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              dateFormat.format(battery.purchasedDate),
              style: TextStyle(
                fontSize: 11,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 44,
              child: Text(
                '${battery.daysPassed} hr',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isOverdue ? const Color(0xFFEF4444) : primaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompactLiquidRowView extends StatelessWidget {
  final LiquidItem liquid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CompactLiquidRowView({
    super.key,
    required this.liquid,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final secondaryTextColor = const Color(0xFF8E8E93);

    final isOverdue = liquid.healthStatus.isOverdue;
    final dateFormat = DateFormat('dd/MM/yy');

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.water_drop_rounded,
              size: 14,
              color: Color(0xFF007AFF),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    liquid.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${liquid.nicMg} • ${liquid.volumeMl}',
                    style: TextStyle(
                      fontSize: 10,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              dateFormat.format(liquid.openedDate),
              style: TextStyle(
                fontSize: 11,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 44,
              child: Text(
                '${liquid.daysPassed} hr',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isOverdue ? const Color(0xFFEF4444) : primaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
