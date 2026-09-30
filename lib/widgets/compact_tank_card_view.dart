import 'package:flutter/material.dart';
import '../models/vape_entities.dart';

class CompactTankCardView extends StatelessWidget {
  final TankSetup tank;
  final List<String> availableLiquids;
  final ValueChanged<String> onSelectLiquid;
  final VoidCallback onQuickResetCoil;
  final VoidCallback onQuickResetCotton;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CompactTankCardView({
    super.key,
    required this.tank,
    required this.availableLiquids,
    required this.onSelectLiquid,
    required this.onQuickResetCoil,
    required this.onQuickResetCotton,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final pillBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final dividerColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final secondaryTextColor = const Color(0xFF8E8E93);

    final isCoilOverdue = tank.coilHealthStatus.isOverdue;
    final isCottonOverdue = tank.cottonHealthStatus.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onEdit,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tank.tankName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tank.wireType,
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Liquid Selector Pill / Menu
                PopupMenuButton<String>(
                  color: cardBg,
                  surfaceTintColor: cardBg,
                  onSelected: onSelectLiquid,
                  itemBuilder: (context) => availableLiquids.map((liq) {
                    return PopupMenuItem<String>(
                      value: liq,
                      child: Text(
                        liq,
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryTextColor,
                        ),
                      ),
                    );
                  }).toList(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.water_drop_rounded,
                          size: 11,
                          color: Color(0xFF007AFF),
                        ),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            tank.activeLiquidName.isEmpty
                                ? 'Pilih Liquid'
                                : tank.activeLiquidName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF007AFF),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14,
                          color: Color(0xFF007AFF),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: dividerColor,
            indent: 14,
            endIndent: 14,
          ),

          // Metrics Row
          Row(
            children: [
              // Coil Metric
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COIL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${tank.coilDaysPassed}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isCoilOverdue
                                      ? const Color(0xFFEF4444)
                                      : (tank.coilDaysPassed >= 10
                                          ? const Color(0xFFFF9500)
                                          : primaryTextColor),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'hari',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: onQuickResetCoil,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: pillBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                width: 1,
                height: 32,
                color: dividerColor,
              ),

              // Cotton Metric
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KAPAS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${tank.cottonDaysPassed}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isCottonOverdue
                                      ? const Color(0xFFEF4444)
                                      : primaryTextColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'hari',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: onQuickResetCotton,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: pillBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
