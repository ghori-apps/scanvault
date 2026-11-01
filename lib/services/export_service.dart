import 'dart:convert';
import '../models/scanned_code.dart';

/// Service for exporting scan vault records to CSV, JSON, or TXT formats.
class ExportService {
  static String toCsv(List<ScannedCode> items) {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('"Date","Type","Format","Title","Raw Value","Is Favorite"');

    for (var item in items) {
      final date = item.scannedAt.toIso8601String();
      final type = item.contentType.name;
      final format = item.format;
      final title = _cleanCsv(item.parsedContent.title);
      final raw = _cleanCsv(item.rawValue);
      final fav = item.isFavorite ? 'Yes' : 'No';

      buffer.writeln('"$date","$type","$format","$title","$raw","$fav"');
    }

    return buffer.toString();
  }

  static String toJsonString(List<ScannedCode> items) {
    final list = items.map((e) => e.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  static String toTxt(List<ScannedCode> items) {
    final buffer = StringBuffer();
    buffer.writeln('=== ScanVault Export (${items.length} items) ===\n');

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      buffer.writeln('${i + 1}. [${item.contentType.label}] ${item.parsedContent.title}');
      buffer.writeln('   Scanned: ${item.scannedAt}');
      buffer.writeln('   Format: ${item.format}');
      buffer.writeln('   Value: ${item.rawValue}');
      if (item.note != null && item.note!.isNotEmpty) {
        buffer.writeln('   Note: ${item.note}');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  static String _cleanCsv(String text) {
    return text.replaceAll('"', '""').replaceAll('\n', ' ');
  }
}
