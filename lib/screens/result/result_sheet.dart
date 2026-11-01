import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../models/content_type.dart';
import '../../models/scanned_code.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/safety_service.dart';
import '../../widgets/sv_button.dart';
import '../../widgets/sv_card.dart';
import 'url_safety_warning.dart';

class ResultSheet extends StatefulWidget {
  final ScannedCode code;
  final VoidCallback? onClose;

  const ResultSheet({
    super.key,
    required this.code,
    this.onClose,
  });

  @override
  State<ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends State<ResultSheet> {
  late SafetyAnalysisResult _safetyResult;

  @override
  void initState() {
    super.initState();
    if (widget.code.contentType == CodeContentType.url) {
      _safetyResult = SafetyService.analyzeUrl(widget.code.rawValue);
    } else {
      _safetyResult = const SafetyAnalysisResult(
        status: SafetyStatus.safe,
        title: 'Safe',
        description: '',
        warningFlags: [],
      );
    }
  }

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
      case CodeContentType.text:
        return Icons.text_snippet_rounded;
      case CodeContentType.unknown:
        return Icons.qr_code_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyProvider = Provider.of<HistoryProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final parsed = widget.code.parsedContent;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.mediumGray.withValues(alpha: 0.5) : AppColors.borderGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row: Format badge + Favorite toggle + Close
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.electricCoral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.code.format.replaceAll('_', ' '),
                  style: AppTypography.labelSmall(isDark: isDark).copyWith(
                    color: AppColors.electricCoral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  widget.code.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: widget.code.isFavorite ? AppColors.restrainedAmber : AppColors.mediumGray,
                ),
                onPressed: () => historyProvider.toggleFavorite(widget.code),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (widget.onClose != null) widget.onClose!();
                },
              ),
            ],
          ),

          // Title & Subtitle Card
          SVCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.electricCoral.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getTypeIcon(widget.code.contentType),
                    color: AppColors.electricCoral,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parsed.title,
                        style: AppTypography.titleLarge(isDark: isDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        parsed.subtitle,
                        style: AppTypography.bodySmall(isDark: isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Safety Warning Banner for URLs
          if (widget.code.contentType == CodeContentType.url) ...[
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => UrlSafetyWarningDialog(
                    url: widget.code.rawValue,
                    result: _safetyResult,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _safetyResult.status == SafetyStatus.safe
                      ? AppColors.safeGreen.withValues(alpha: 0.1)
                      : (_safetyResult.status == SafetyStatus.suspicious
                          ? AppColors.warningAmber.withValues(alpha: 0.1)
                          : AppColors.dangerRed.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _safetyResult.status == SafetyStatus.safe
                        ? AppColors.safeGreen
                        : (_safetyResult.status == SafetyStatus.suspicious
                            ? AppColors.warningAmber
                            : AppColors.dangerRed),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _safetyResult.status == SafetyStatus.safe
                          ? Icons.shield_rounded
                          : Icons.warning_amber_rounded,
                      color: _safetyResult.status == SafetyStatus.safe
                          ? AppColors.safeGreen
                          : (_safetyResult.status == SafetyStatus.suspicious
                              ? AppColors.warningAmber
                              : AppColors.dangerRed),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _safetyResult.title,
                        style: AppTypography.bodySmall(isDark: isDark).copyWith(
                          fontWeight: FontWeight.w600,
                          color: _safetyResult.status == SafetyStatus.safe
                              ? AppColors.safeGreen
                              : (_safetyResult.status == SafetyStatus.suspicious
                                  ? AppColors.warningAmber
                                  : AppColors.dangerRed),
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Fields Table
          if (parsed.fields.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightGray,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: parsed.fields.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            entry.key,
                            style: AppTypography.labelSmall(isDark: isDark).copyWith(
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SelectableText(
                            entry.value,
                            style: AppTypography.bodySmall(isDark: isDark).copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Primary & Action Buttons
          Row(
            children: [
              // Copy Button
              Expanded(
                child: SVButton(
                  label: 'Copy',
                  icon: Icons.copy_rounded,
                  variant: SVButtonVariant.secondary,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.code.rawValue));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Primary Contextual Action Button
              Expanded(
                child: SVButton(
                  label: _getPrimaryActionLabel(widget.code.contentType),
                  icon: _getPrimaryActionIcon(widget.code.contentType),
                  variant: SVButtonVariant.primary,
                  onPressed: () => _handlePrimaryAction(context, widget.code, settingsProvider.neverAutoOpenUrls),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Share Action Button
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share Code Payload'),
              onPressed: () {
                SharePlus.instance.share(ShareParams(text: widget.code.rawValue, subject: parsed.title));
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getPrimaryActionLabel(CodeContentType type) {
    switch (type) {
      case CodeContentType.url:
        return 'Open URL';
      case CodeContentType.wifi:
        return 'Join Wi-Fi';
      case CodeContentType.contact:
        return 'Save Contact';
      case CodeContentType.email:
        return 'Send Email';
      case CodeContentType.sms:
        return 'Send SMS';
      case CodeContentType.phone:
        return 'Call Number';
      case CodeContentType.geo:
        return 'Open Map';
      case CodeContentType.calendar:
        return 'Add Event';
      case CodeContentType.product:
      case CodeContentType.isbn:
        return 'Search Product';
      default:
        return 'Share Text';
    }
  }

  IconData _getPrimaryActionIcon(CodeContentType type) {
    switch (type) {
      case CodeContentType.url:
        return Icons.open_in_new_rounded;
      case CodeContentType.wifi:
        return Icons.wifi_rounded;
      case CodeContentType.contact:
        return Icons.person_add_rounded;
      case CodeContentType.email:
        return Icons.send_rounded;
      case CodeContentType.sms:
        return Icons.sms_rounded;
      case CodeContentType.phone:
        return Icons.call_rounded;
      case CodeContentType.geo:
        return Icons.map_rounded;
      case CodeContentType.calendar:
        return Icons.event_available_rounded;
      case CodeContentType.product:
      case CodeContentType.isbn:
        return Icons.search_rounded;
      default:
        return Icons.share_rounded;
    }
  }

  void _handlePrimaryAction(BuildContext context, ScannedCode code, bool neverAutoOpen) {
    if (code.contentType == CodeContentType.url) {
      if (neverAutoOpen || _safetyResult.status != SafetyStatus.safe) {
        showDialog(
          context: context,
          builder: (_) => UrlSafetyWarningDialog(
            url: code.rawValue,
            result: _safetyResult,
          ),
        );
      } else {
        launchUrl(Uri.parse(code.rawValue), mode: LaunchMode.externalApplication);
      }
    } else if (code.contentType == CodeContentType.phone) {
      launchUrl(Uri.parse('tel:${code.rawValue}'));
    } else if (code.contentType == CodeContentType.email) {
      launchUrl(Uri.parse(code.rawValue.startsWith('mailto:') ? code.rawValue : 'mailto:${code.rawValue}'));
    } else if (code.contentType == CodeContentType.product || code.contentType == CodeContentType.isbn) {
      final searchUrl = 'https://www.google.com/search?q=${code.rawValue}';
      launchUrl(Uri.parse(searchUrl), mode: LaunchMode.externalApplication);
    } else if (code.contentType == CodeContentType.geo) {
      final geoUrl = 'https://maps.google.com/?q=${code.parsedContent.fields['Latitude']},${code.parsedContent.fields['Longitude']}';
      launchUrl(Uri.parse(geoUrl), mode: LaunchMode.externalApplication);
    } else {
      SharePlus.instance.share(ShareParams(text: code.rawValue));
    }
  }
}
