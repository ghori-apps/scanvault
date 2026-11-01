import '../models/content_type.dart';
import '../models/parsed_content.dart';

/// Smart Result Action Parser engine for ScanVault.
class ParserService {
  static ParsedContent parse(String rawValue, String format) {
    final raw = rawValue.trim();

    // 1. URL Check
    if (raw.toLowerCase().startsWith('http://') ||
        raw.toLowerCase().startsWith('https://') ||
        raw.toLowerCase().startsWith('www.')) {
      final url = raw.toLowerCase().startsWith('www.') ? 'https://$raw' : raw;
      final uri = Uri.tryParse(url);
      final host = uri?.host ?? 'Web Link';
      return ParsedContent(
        type: CodeContentType.url,
        title: host.isNotEmpty ? host : 'Web Link',
        subtitle: url,
        fields: {'URL': url, 'Host': host},
        rawValue: rawValue,
      );
    }

    // 2. Wi-Fi Check
    if (raw.toUpperCase().startsWith('WIFI:')) {
      final ssidMatch = RegExp(r'S:([^;]+);', caseSensitive: false).firstMatch(raw);
      final passMatch = RegExp(r'P:([^;]+);', caseSensitive: false).firstMatch(raw);
      final typeMatch = RegExp(r'T:([^;]+);', caseSensitive: false).firstMatch(raw);

      final ssid = ssidMatch?.group(1) ?? 'Unknown Network';
      final pass = passMatch?.group(1) ?? '';
      final security = typeMatch?.group(1) ?? 'WPA/WPA2';

      return ParsedContent(
        type: CodeContentType.wifi,
        title: ssid,
        subtitle: 'Wi-Fi Network ($security)',
        fields: {
          'SSID': ssid,
          'Password': pass.isNotEmpty ? pass : '(No Password)',
          'Security': security,
        },
        rawValue: rawValue,
      );
    }

    // 3. vCard / Contact Check
    if (raw.toUpperCase().contains('BEGIN:VCARD')) {
      final nameMatch = RegExp(r'FN:(.*?)(\r?\n|\r)', caseSensitive: false).firstMatch(raw) ??
          RegExp(r'N:(.*?)(\r?\n|\r)', caseSensitive: false).firstMatch(raw);
      final telMatch = RegExp(r'TEL.*?:(.*?)(\r?\n|\r)', caseSensitive: false).firstMatch(raw);
      final emailMatch = RegExp(r'EMAIL.*?:(.*?)(\r?\n|\r)', caseSensitive: false).firstMatch(raw);
      final orgMatch = RegExp(r'ORG:(.*?)(\r?\n|\r)', caseSensitive: false).firstMatch(raw);

      final name = nameMatch?.group(1)?.trim() ?? 'Contact';
      final phone = telMatch?.group(1)?.trim() ?? '';
      final email = emailMatch?.group(1)?.trim() ?? '';
      final org = orgMatch?.group(1)?.trim() ?? '';

      final fields = <String, String>{
        if (name.isNotEmpty) 'Name': name,
        if (phone.isNotEmpty) 'Phone': phone,
        if (email.isNotEmpty) 'Email': email,
        if (org.isNotEmpty) 'Company': org,
      };

      return ParsedContent(
        type: CodeContentType.contact,
        title: name,
        subtitle: phone.isNotEmpty ? phone : email,
        fields: fields,
        rawValue: rawValue,
      );
    }

    // 4. Email Check
    if (raw.toLowerCase().startsWith('mailto:')) {
      final uri = Uri.tryParse(raw);
      final email = uri?.path ?? raw.substring(7);
      final subject = uri?.queryParameters['subject'] ?? '';
      final body = uri?.queryParameters['body'] ?? '';

      return ParsedContent(
        type: CodeContentType.email,
        title: email,
        subtitle: subject.isNotEmpty ? 'Subject: $subject' : 'Email Address',
        fields: {
          'To': email,
          if (subject.isNotEmpty) 'Subject': subject,
          if (body.isNotEmpty) 'Body': body,
        },
        rawValue: rawValue,
      );
    }

    // 5. SMS Check
    if (raw.toLowerCase().startsWith('smsto:') || raw.toLowerCase().startsWith('sms:')) {
      final parts = raw.split(':');
      final number = parts.length > 1 ? parts[1].split('?')[0] : '';
      final message = parts.length > 2 ? parts[2] : '';

      return ParsedContent(
        type: CodeContentType.sms,
        title: number.isNotEmpty ? number : 'SMS',
        subtitle: message.isNotEmpty ? message : 'Send SMS Message',
        fields: {
          'Number': number,
          if (message.isNotEmpty) 'Message': message,
        },
        rawValue: rawValue,
      );
    }

    // 6. Phone Check
    if (raw.toLowerCase().startsWith('tel:')) {
      final phone = raw.substring(4);
      return ParsedContent(
        type: CodeContentType.phone,
        title: phone,
        subtitle: 'Phone Number',
        fields: {'Phone': phone},
        rawValue: rawValue,
      );
    }

    // 7. Geo Location Check
    if (raw.toLowerCase().startsWith('geo:')) {
      final coords = raw.substring(4).split('?')[0];
      final parts = coords.split(',');
      final lat = parts.isNotEmpty ? parts[0] : '0';
      final lon = parts.length > 1 ? parts[1] : '0';

      return ParsedContent(
        type: CodeContentType.geo,
        title: 'Coordinates: $lat, $lon',
        subtitle: 'Geographic Location',
        fields: {'Latitude': lat, 'Longitude': lon},
        rawValue: rawValue,
      );
    }

    // 8. Calendar Event Check
    if (raw.toUpperCase().contains('BEGIN:VEVENT')) {
      final summaryMatch = RegExp(r'SUMMARY:(.*?)(\r?\n|\r)', caseSensitive: false).firstMatch(raw);
      final locationMatch = RegExp(r'LOCATION:(.*?)(\r?\n|\r)', caseSensitive: false).firstMatch(raw);

      final summary = summaryMatch?.group(1)?.trim() ?? 'Event';
      final location = locationMatch?.group(1)?.trim() ?? '';

      return ParsedContent(
        type: CodeContentType.calendar,
        title: summary,
        subtitle: location.isNotEmpty ? 'Location: $location' : 'Calendar Event',
        fields: {
          'Title': summary,
          if (location.isNotEmpty) 'Location': location,
        },
        rawValue: rawValue,
      );
    }

    // 9. Product Barcode / ISBN Check
    final isProductFormat = format.contains('EAN') || format.contains('UPC') || format.contains('PRODUCT');
    if (isProductFormat || (RegExp(r'^\d{8,13}$').hasMatch(raw))) {
      final isIsbn = raw.startsWith('978') || raw.startsWith('979');
      return ParsedContent(
        type: isIsbn ? CodeContentType.isbn : CodeContentType.product,
        title: isIsbn ? 'ISBN: $raw' : 'Product Code: $raw',
        subtitle: 'Format: $format',
        fields: {
          'Code': raw,
          'Format': format,
        },
        rawValue: rawValue,
      );
    }

    // 10. Default Plain Text
    return ParsedContent(
      type: CodeContentType.text,
      title: raw.length > 40 ? '${raw.substring(0, 40)}...' : raw,
      subtitle: 'Plain Text (${raw.length} chars)',
      fields: {'Text': raw},
      rawValue: rawValue,
    );
  }
}
