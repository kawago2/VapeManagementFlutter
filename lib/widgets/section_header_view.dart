import 'package:flutter/material.dart';

class SectionHeaderView extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onAdd;

  const SectionHeaderView({
    super.key,
    required this.title,
    required this.count,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($count)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFAEAEB2),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: buttonBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 14,
                color: Color(0xFF8E8E93),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
