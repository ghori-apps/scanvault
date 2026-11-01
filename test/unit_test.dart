import 'package:flutter_test/flutter_test.dart';
import 'package:scanvault/models/content_type.dart';
import 'package:scanvault/services/parser_service.dart';
import 'package:scanvault/services/safety_service.dart';

void main() {
  group('Smart Result Parser Tests', () {
    test('Parse Web URL', () {
      final result = ParserService.parse('https://example.com/page', 'QR_CODE');
      expect(result.type, equals(CodeContentType.url));
      expect(result.title, equals('example.com'));
      expect(result.fields['URL'], equals('https://example.com/page'));
    });

    test('Parse Wi-Fi Credentials', () {
      final result = ParserService.parse('WIFI:S:HomeNet;T:WPA;P:secret123;;', 'QR_CODE');
      expect(result.type, equals(CodeContentType.wifi));
      expect(result.title, equals('HomeNet'));
      expect(result.fields['Password'], equals('secret123'));
    });

    test('Parse vCard Contact', () {
      final raw = 'BEGIN:VCARD\nFN:Jane Doe\nTEL:+15550199\nEMAIL:jane@example.com\nEND:VCARD';
      final result = ParserService.parse(raw, 'QR_CODE');
      expect(result.type, equals(CodeContentType.contact));
      expect(result.title, equals('Jane Doe'));
      expect(result.fields['Phone'], equals('+15550199'));
    });

    test('Parse EAN-13 Product Barcode', () {
      final result = ParserService.parse('8901234567890', 'EAN_13');
      expect(result.type, equals(CodeContentType.product));
      expect(result.fields['Code'], equals('8901234567890'));
    });
  });

  group('Offline URL Safety Heuristic Tests', () {
    test('Safe Standard Domain', () {
      final analysis = SafetyService.analyzeUrl('https://google.com');
      expect(analysis.status, equals(SafetyStatus.safe));
    });

    test('Suspicious IP Address Domain', () {
      final analysis = SafetyService.analyzeUrl('http://192.168.1.1/login');
      expect(analysis.status, equals(SafetyStatus.suspicious));
      expect(analysis.warningFlags, contains('Uses raw IP address instead of domain name'));
    });

    test('High Risk Multiple Warnings', () {
      final analysis = SafetyService.analyzeUrl('http://admin:pass@login.bank.security.verify.account.xyz');
      expect(analysis.status, equals(SafetyStatus.dangerous));
    });
  });
}
