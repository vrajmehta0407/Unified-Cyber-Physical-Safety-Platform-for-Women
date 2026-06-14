import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

/// [GAP 2] Offline SMS alert with GPS coordinates via telephony/SMS URI
class SmsFallbackService {
  Future<bool> sendSosSms({
    required List<String> phoneNumbers,
    required double lat,
    required double lng,
    String message = 'SOS! I need help. My location:',
  }) async {
    // Sanitize phone numbers (remove spaces, hyphens, etc. Keep digits and +)
    final List<String> cleanNumbers = phoneNumbers
        .map((num) => num.replaceAll(RegExp(r'[^0-9+]'), ''))
        .where((num) => num.isNotEmpty)
        .toList();

    if (cleanNumbers.isEmpty) {
      cleanNumbers.add('112');
    }

    final smsText = '$message https://maps.google.com/?q=$lat,$lng';
    
    // Construct SMS URI. For Android, separators can be ';' or ';'.
    // However, url_launcher on Android is most reliable using the 'sms:' scheme 
    // with query parameter encoding.
    final separator = Platform.isAndroid ? ';' : ',';
    final path = cleanNumbers.join(separator);
    
    final Uri uri = Uri(
      scheme: 'sms',
      path: path,
      queryParameters: {
        'body': smsText,
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        // Fallback for single number
        final Uri singleUri = Uri(
          scheme: 'sms',
          path: cleanNumbers.first,
          queryParameters: {
            'body': smsText,
          },
        );
        return await launchUrl(singleUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Direct launch fallback without canLaunchUrl checks
      final Uri fallbackUri = Uri(
        scheme: 'sms',
        path: cleanNumbers.first,
        queryParameters: {
          'body': smsText,
        },
      );
      try {
        return await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        throw Exception('Could not launch SMS app: $e');
      }
    }
  }
}

