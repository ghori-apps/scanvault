import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_typography.dart';

class SVBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SVBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _NavItem(icon: Icons.qr_code_scanner_rounded, activeIcon: Icons.qr_code_scanner_rounded, label: 'Scanner'),
      _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded, label: 'Vault'),
      _NavItem(icon: Icons.add_box_outlined, activeIcon: Icons.add_box_rounded, label: 'Create'),
      _NavItem(icon: Icons.tune_rounded, activeIcon: Icons.tune_rounded, label: 'Settings'),
    ];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.warmWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;
            final item = items[index];
            final color = isSelected
                ? AppColors.electricCoral
                : (isDark ? AppColors.mediumGray : AppColors.mediumGray);

            return Expanded(
              child: _NavItemWidget(
                item: item,
                isSelected: isSelected,
                isDark: isDark,
                color: color,
                onTap: () => onTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isDark;
  final Color color;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.color,
    required this.onTap,
  });

  @override
  State<_NavItemWidget> createState() => _NavItemWidgetState();
}

class _NavItemWidgetState extends State<_NavItemWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: InkWell(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: widget.isSelected ? AppColors.electricCoral.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                color: widget.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.item.label,
              style: AppTypography.labelSmall(isDark: widget.isDark).copyWith(
                color: widget.color,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
