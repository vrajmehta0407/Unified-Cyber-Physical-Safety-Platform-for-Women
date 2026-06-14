import 'package:flutter/services.dart';

/// Service to send OTP via native SMS using platform channel.
/// Uses Android's SmsManager to send text messages directly.
class SmsOtpService {
  static const _channel = MethodChannel('com.cybershield/sms');

  /// Send OTP code via SMS to the given phone number.
  /// Returns true if SMS was sent successfully.
  /// Throws [PlatformException] if SMS permission is denied or sending fails.
  Future<bool> sendOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    // Ensure phone number has country code for India
    String formattedNumber = phoneNumber.trim();
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = '+91$formattedNumber';
    }

    final message = 'Your CyberShield verification code is: $otp. '
        'Do not share this code with anyone. Valid for 5 minutes.';

    try {
      final result = await _channel.invokeMethod('sendSms', {
        'phoneNumber': formattedNumber,
        'message': message,
      });
      return result == true;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        throw Exception(
          'SMS permission denied. Please allow SMS permission in Settings to receive OTP via text message.',
        );
      }
      throw Exception('Failed to send SMS: ${e.message}');
    }
  }

  /// Check if SMS permission is granted.
  Future<bool> hasSmsPermission() async {
    try {
      final result = await _channel.invokeMethod('checkSmsPermission');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  /// Request SMS permission from user.
  Future<void> requestSmsPermission() async {
    try {
      await _channel.invokeMethod('requestSmsPermission');
    } catch (_) {
      // Permission request UI shown natively
    }
  }
}
