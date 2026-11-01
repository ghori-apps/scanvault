import 'package:flutter/material.dart';
import 'content_type.dart';

/// Style configuration for custom QR codes.
class QRStyle {
  final int foregroundColorHex;
  final int backgroundColorHex;
  final String cornerStyle; // 'square', 'rounded', 'circle'

  const QRStyle({
    this.foregroundColorHex = 0xFF2D2926,
    this.backgroundColorHex = 0xFFFAF6F1,
    this.cornerStyle = 'rounded',
  });

  Color get foregroundColor => Color(foregroundColorHex);
  Color get backgroundColor => Color(backgroundColorHex);

  Map<String, dynamic> toJson() => {
        'foregroundColorHex': foregroundColorHex,
        'backgroundColorHex': backgroundColorHex,
        'cornerStyle': cornerStyle,
      };

  factory QRStyle.fromJson(Map<String, dynamic> json) {
    return QRStyle(
      foregroundColorHex: json['foregroundColorHex'] ?? 0xFF2D2926,
      backgroundColorHex: json['backgroundColorHex'] ?? 0xFFFAF6F1,
      cornerStyle: json['cornerStyle'] ?? 'rounded',
    );
  }
}

/// Data model representing a user-created QR code.
class GeneratedCode {
  final String id;
  final String title;
  final String rawValue;
  final CodeContentType contentType;
  final QRStyle style;
  final DateTime createdAt;

  GeneratedCode({
    required this.id,
    required this.title,
    required this.rawValue,
    required this.contentType,
    this.style = const QRStyle(),
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'rawValue': rawValue,
        'contentType': contentType.name,
        'style': style.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory GeneratedCode.fromJson(Map<String, dynamic> json) {
    return GeneratedCode(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled QR',
      rawValue: json['rawValue'] ?? '',
      contentType: CodeContentType.values.firstWhere(
        (e) => e.name == json['contentType'],
        orElse: () => CodeContentType.text,
      ),
      style: QRStyle.fromJson(json['style'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
