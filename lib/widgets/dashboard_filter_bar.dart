import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum DashboardTab {
  overview('Semua', CupertinoIcons.square_grid_2x2),
  tanks('Tank & Coil', CupertinoIcons.circle_grid_hex),
  batteries('Baterai', CupertinoIcons.battery_charging),
  liquids('Liquid', CupertinoIcons.drop_fill);

  final String label;
  final IconData icon;
  const DashboardTab(this.label, this.icon);
}

class DashboardFilterBar extends StatelessWidget {
  final DashboardTab selectedTab;
  final ValueChanged<DashboardTab> onTabSelected;

  const DashboardFilterBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final activeBg = const Color(0xFF007AFF);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DashboardTab.values.map((tab) {
          final isSelected = selectedTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onTabSelected(tab),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? activeBg.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.icon,
                      size: 13,
                      color: isSelected ? Colors.white : primaryTextColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
