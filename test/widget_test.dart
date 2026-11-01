import 'package:flutter_test/flutter_test.dart';
import 'package:scanvault/models/content_type.dart';
import 'package:scanvault/services/parser_service.dart';

void main() {
  test('Smart Parser Unit Verification', () {
    final result = ParserService.parse('https://scanvault.app', 'QR_CODE');
    expect(result.type, equals(CodeContentType.url));
    expect(result.title, equals('scanvault.app'));
  });
}
