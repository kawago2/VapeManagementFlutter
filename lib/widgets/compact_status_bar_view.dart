import 'package:flutter/material.dart';

class CompactStatusBarView extends StatelessWidget {
  final int overdueCoilCount;
  final int overdueCottonCount;

  const CompactStatusBarView({
    super.key,
    required this.overdueCoilCount,
    required this.overdueCottonCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final secondaryTextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);

    return Row(
      children: [
        // Coil Summary Pill
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: overdueCoilCount > 0
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS COIL',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      overdueCoilCount > 0
                          ? '$overdueCoilCount Perlu Cek'
                          : 'Semua Aman',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: overdueCoilCount > 0
                            ? const Color(0xFFEF4444)
                            : primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Cotton Summary Pill
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: overdueCottonCount > 0
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS KAPAS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      overdueCottonCount > 0
                          ? '$overdueCottonCount Perlu Ganti'
                          : 'Semua Aman',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: overdueCottonCount > 0
                            ? const Color(0xFFEF4444)
                            : primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
