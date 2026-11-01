import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../models/content_type.dart';
import '../../models/scanned_code.dart';
import '../../widgets/sv_card.dart';

class HistoryItemTile extends StatelessWidget {
  final ScannedCode code;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;

  const HistoryItemTile({
    super.key,
    required this.code,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  IconData _getTypeIcon(CodeContentType type) {
    switch (type) {
      case CodeContentType.url:
        return Icons.language_rounded;
      case CodeContentType.wifi:
        return Icons.wifi_rounded;
      case CodeContentType.contact:
        return Icons.person_rounded;
      case CodeContentType.email:
        return Icons.email_rounded;
      case CodeContentType.sms:
        return Icons.sms_rounded;
      case CodeContentType.phone:
        return Icons.phone_rounded;
      case CodeContentType.geo:
        return Icons.location_on_rounded;
      case CodeContentType.calendar:
        return Icons.event_rounded;
      case CodeContentType.product:
        return Icons.shopping_bag_rounded;
      case CodeContentType.isbn:
        return Icons.menu_book_rounded;
      default:
        return Icons.text_snippet_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('MMM d, h:mm a').format(code.scannedAt);

    return Dismissible(
      key: Key(code.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.dangerRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: SVCard(
          onTap: onTap,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.electricCoral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(code.contentType),
                  color: AppColors.electricCoral,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code.parsedContent.title,
                      style: AppTypography.titleMedium(isDark: isDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          timeStr,
                          style: AppTypography.labelSmall(isDark: isDark),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  ${code.format}',
                          style: AppTypography.labelSmall(isDark: isDark).copyWith(
                            color: AppColors.electricCoral,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  code.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: code.isFavorite ? AppColors.restrainedAmber : AppColors.mediumGray,
                  size: 22,
                ),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
