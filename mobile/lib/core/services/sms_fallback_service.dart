import 'package:url_launcher/url_launcher.dart';

/// [GAP 2] Offline SMS alert with GPS coordinates via telephony/SMS URI
class SmsFallbackService {
  Future<bool> sendSosSms({
    required List<String> phoneNumbers,
    required double lat,
    required double lng,
    String message = 'SOS! I need help. My location:',
  }) async {
    final body = Uri.encodeComponent('$message https://maps.google.com/?q=$lat,$lng');
    final numbers = phoneNumbers.join(',');
    final uri = Uri.parse('sms:$numbers?body=$body');
    return launchUrl(uri);
  }
}
