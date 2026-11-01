import 'content_type.dart';

/// Parsed data representation of a scanned code.
class ParsedContent {
  final CodeContentType type;
  final String title;
  final String subtitle;
  final Map<String, String> fields;
  final String rawValue;

  const ParsedContent({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.rawValue,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'subtitle': subtitle,
        'fields': fields,
        'rawValue': rawValue,
      };

  factory ParsedContent.fromJson(Map<String, dynamic> json) {
    return ParsedContent(
      type: CodeContentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CodeContentType.text,
      ),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      fields: Map<String, String>.from(json['fields'] ?? {}),
      rawValue: json['rawValue'] ?? '',
    );
  }
}
