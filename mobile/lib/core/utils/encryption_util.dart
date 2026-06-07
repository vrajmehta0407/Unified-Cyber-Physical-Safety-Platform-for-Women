import 'package:encrypt/encrypt.dart' as enc;

class EncryptionUtil {
  static enc.Encrypter _encrypter(String key) {
    final k = enc.Key.fromUtf8(key.padRight(32, '0').substring(0, 32));
    return enc.Encrypter(enc.AES(k, mode: enc.AESMode.gcm));
  }

  static String encrypt(String plainText, String key) {
    final iv = enc.IV.fromSecureRandom(12);
    final encrypted = _encrypter(key).encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }
}
