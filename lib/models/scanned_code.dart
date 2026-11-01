import 'content_type.dart';
import 'parsed_content.dart';

/// Data model representing a scanned QR code or barcode.
class ScannedCode {
  final String id;
  final String rawValue;
  final String format; // e.g. QR_CODE, EAN_13, CODE_128
  final CodeContentType contentType;
  final ParsedContent parsedContent;
  final DateTime scannedAt;
  bool isFavorite;
  String? note;
  final ScanSource source;

  ScannedCode({
    required this.id,
    required this.rawValue,
    required this.format,
    required this.contentType,
    required this.parsedContent,
    required this.scannedAt,
    this.isFavorite = false,
    this.note,
    this.source = ScanSource.camera,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'rawValue': rawValue,
        'format': format,
        'contentType': contentType.name,
        'parsedContent': parsedContent.toJson(),
        'scannedAt': scannedAt.toIso8601String(),
        'isFavorite': isFavorite,
        'note': note,
        'source': source.name,
      };

  factory ScannedCode.fromJson(Map<String, dynamic> json) {
    return ScannedCode(
      id: json['id'] ?? '',
      rawValue: json['rawValue'] ?? '',
      format: json['format'] ?? 'UNKNOWN',
      contentType: CodeContentType.values.firstWhere(
        (e) => e.name == json['contentType'],
        orElse: () => CodeContentType.text,
      ),
      parsedContent: ParsedContent.fromJson(json['parsedContent'] ?? {}),
      scannedAt: DateTime.tryParse(json['scannedAt'] ?? '') ?? DateTime.now(),
      isFavorite: json['isFavorite'] ?? false,
      note: json['note'],
      source: ScanSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => ScanSource.camera,
      ),
    );
  }

  ScannedCode copyWith({
    bool? isFavorite,
    String? note,
  }) {
    return ScannedCode(
      id: id,
      rawValue: rawValue,
      format: format,
      contentType: contentType,
      parsedContent: parsedContent,
      scannedAt: scannedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      note: note ?? this.note,
      source: source,
    );
  }
}
