import '../../ads/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme/app_colors.dart';
import '../../models/content_type.dart';
import '../../providers/history_provider.dart';
import '../../services/export_service.dart';
import '../../widgets/sv_chip.dart';
import '../../widgets/sv_empty_state.dart';
import '../../widgets/sv_search_bar.dart';
import 'history_detail_screen.dart';
import 'history_item_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showExportOptions(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    final items = historyProvider.filteredHistory;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items available to export.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart_rounded, color: AppColors.electricCoral),
              title: const Text('Export as CSV Spreadsheet'),
              onTap: () {
                Navigator.pop(ctx);
                final csv = ExportService.toCsv(items);
                SharePlus.instance.share(ShareParams(text: csv, subject: 'ScanVault Export (CSV)'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.code_rounded, color: AppColors.electricCoral),
              title: const Text('Export as JSON Data'),
              onTap: () {
                Navigator.pop(ctx);
                final json = ExportService.toJsonString(items);
                SharePlus.instance.share(ShareParams(text: json, subject: 'ScanVault Export (JSON)'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.article_rounded, color: AppColors.electricCoral),
              title: const Text('Export as Plain Text'),
              onTap: () {
                Navigator.pop(ctx);
                final txt = ExportService.toTxt(items);
                SharePlus.instance.share(ShareParams(text: txt, subject: 'ScanVault Export (TXT)'));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final items = historyProvider.filteredHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Vault',
            onPressed: () => _showExportOptions(context),
          ),
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Clear History',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Scan History?'),
                    content: const Text('This will delete all saved scans from your local storage.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          historyProvider.clearAll();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear All', style: TextStyle(color: AppColors.dangerRed)),
                      ),
                    const SafeArea(top: false, child: AdBannerWidget()),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SVSearchBar(
              controller: _searchController,
              hintText: 'Search history by title, URL, text...',
              onChanged: (q) => historyProvider.setSearchQuery(q),
            ),
          ),

          // Filter Chips Horizontal Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                SVChip(
                  label: 'All (${historyProvider.history.length})',
                  isSelected: !historyProvider.showFavoritesOnly && historyProvider.selectedTypeFilter == null,
                  onTap: () {
                    historyProvider.toggleFavoritesOnly(false);
                    historyProvider.setTypeFilter(null);
                  },
                ),
                const SizedBox(width: 8),
                SVChip(
                  label: 'Favorites ⭐ (${historyProvider.favorites.length})',
                  isSelected: historyProvider.showFavoritesOnly,
                  onTap: () => historyProvider.toggleFavoritesOnly(!historyProvider.showFavoritesOnly),
                ),
                const SizedBox(width: 8),
                SVChip(
                  label: 'Web URLs',
                  isSelected: historyProvider.selectedTypeFilter == CodeContentType.url,
                  onTap: () => historyProvider.setTypeFilter(
                    historyProvider.selectedTypeFilter == CodeContentType.url ? null : CodeContentType.url,
                  ),
                ),
                const SizedBox(width: 8),
                SVChip(
                  label: 'Wi-Fi',
                  isSelected: historyProvider.selectedTypeFilter == CodeContentType.wifi,
                  onTap: () => historyProvider.setTypeFilter(
                    historyProvider.selectedTypeFilter == CodeContentType.wifi ? null : CodeContentType.wifi,
                  ),
                ),
                const SizedBox(width: 8),
                SVChip(
                  label: 'Contacts',
                  isSelected: historyProvider.selectedTypeFilter == CodeContentType.contact,
                  onTap: () => historyProvider.setTypeFilter(
                    historyProvider.selectedTypeFilter == CodeContentType.contact ? null : CodeContentType.contact,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List or Empty State
          Expanded(
            child: historyProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : (items.isEmpty
                    ? SVEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: historyProvider.showFavoritesOnly
                            ? 'No Favorites Yet'
                            : 'Your Vault is Empty',
                        subtitle: 'Scanned QR codes and barcodes will appear here automatically.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final code = items[index];
                          return HistoryItemTile(
                            code: code,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => HistoryDetailScreen(code: code),
                                ),
                              );
                            },
                            onFavoriteToggle: () => historyProvider.toggleFavorite(code),
                            onDelete: () => historyProvider.deleteScan(code),
                          );
                        },
                      )),
          ),
        const SafeArea(top: false, child: AdBannerWidget()),
        ],
      ),
    );
  }
}

