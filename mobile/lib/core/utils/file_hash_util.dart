import 'package:crypto/crypto.dart' as crypto;

class FileHashUtil {
  static String sha256(List<int> bytes) {
    return crypto.sha256.convert(bytes).toString();
  }
}
