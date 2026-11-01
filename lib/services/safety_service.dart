enum SafetyStatus {
  safe,
  suspicious,
  dangerous,
}

class SafetyAnalysisResult {
  final SafetyStatus status;
  final String title;
  final String description;
  final List<String> warningFlags;

  const SafetyAnalysisResult({
    required this.status,
    required this.title,
    required this.description,
    required this.warningFlags,
  });
}

/// Offline URL Safety Heuristic Engine for ScanVault.
class SafetyService {
  static const Set<String> _suspiciousTlds = {
    'xyz', 'top', 'work', 'click', 'gq', 'cf', 'tk', 'ml', 'ga', 'zip', 'mov'
  };

  static const Set<String> _urlShorteners = {
    'bit.ly', 't.co', 'tinyurl.com', 'is.gd', 'buff.ly', 'ow.ly', 'goo.gl', 'cutt.ly'
  };

  static SafetyAnalysisResult analyzeUrl(String urlString) {
    final flags = <String>[];
    Uri? uri;

    try {
      uri = Uri.parse(urlString);
    } catch (_) {
      return const SafetyAnalysisResult(
        status: SafetyStatus.suspicious,
        title: 'Malformed Web Link',
        description: 'This URL could not be properly parsed.',
        warningFlags: ['Invalid URL format'],
      );
    }

    final host = uri.host.toLowerCase();

    // 1. IP Address Host check
    if (RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(host)) {
      flags.add('Uses raw IP address instead of domain name');
    }

    // 2. Embedded credentials check (user:pass@host)
    if (uri.userInfo.isNotEmpty) {
      flags.add('Contains embedded credentials in link');
    }

    // 3. Excessive subdomains check
    final hostParts = host.split('.');
    if (hostParts.length > 4) {
      flags.add('Unusual number of subdomains (${hostParts.length} levels)');
    }

    // 4. Suspicious TLD check
    if (hostParts.length >= 2) {
      final tld = hostParts.last;
      if (_suspiciousTlds.contains(tld)) {
        flags.add('Uses high-risk top-level domain (.$tld)');
      }
    }

    // 5. URL Shortener check
    if (_urlShorteners.contains(host)) {
      flags.add('Uses URL shortener (destination is masked)');
    }

    // 6. Non-standard port check
    if (uri.hasPort && uri.port != 80 && uri.port != 443) {
      flags.add('Uses non-standard network port (${uri.port})');
    }

    // 7. Non-HTTPS check
    if (uri.scheme == 'http') {
      flags.add('Unencrypted connection (HTTP instead of HTTPS)');
    }

    if (flags.isEmpty) {
      return const SafetyAnalysisResult(
        status: SafetyStatus.safe,
        title: 'Domain Verified',
        description: 'No known security risk factors detected by local heuristics.',
        warningFlags: [],
      );
    } else if (flags.length >= 3 || host.contains('@')) {
      return SafetyAnalysisResult(
        status: SafetyStatus.dangerous,
        title: 'High Risk Link Warning',
        description: 'Multiple security risk factors detected. Proceed with extreme caution.',
        warningFlags: flags,
      );
    } else {
      return SafetyAnalysisResult(
        status: SafetyStatus.suspicious,
        title: 'Link Safety Notice',
        description: 'Review domain details carefully before opening.',
        warningFlags: flags,
      );
    }
  }
}
