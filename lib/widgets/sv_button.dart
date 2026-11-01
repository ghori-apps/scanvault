import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_typography.dart';

enum SVButtonVariant {
  primary,
  secondary,
  outline,
  danger,
}

class SVButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final SVButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;

  const SVButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = SVButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  State<SVButton> createState() => _SVButtonState();
}

class _SVButtonState extends State<SVButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (widget.variant) {
      case SVButtonVariant.primary:
        bg = AppColors.electricCoral;
        fg = Colors.white;
        break;
      case SVButtonVariant.secondary:
        bg = isDark ? AppColors.darkCard : AppColors.lightGray;
        fg = isDark ? AppColors.warmIvory : AppColors.graphite;
        break;
      case SVButtonVariant.outline:
        bg = Colors.transparent;
        fg = isDark ? AppColors.warmIvory : AppColors.graphite;
        border = BorderSide(color: isDark ? AppColors.mediumGray : AppColors.borderGray, width: 1.5);
        break;
      case SVButtonVariant.danger:
        bg = AppColors.dangerRed;
        fg = Colors.white;
        break;
    }

    Widget child = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: fg),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: AppTypography.titleMedium(isDark: isDark).copyWith(
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: SizedBox(
        height: 52,
        width: widget.fullWidth ? double.infinity : null,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.fromBorderSide(border),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
