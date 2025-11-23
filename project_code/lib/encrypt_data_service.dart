// source code from @afridi.khondakar on medium
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptDataService {
  // The singleton instance
  static final EncryptDataService _instance = EncryptDataService._internal();

  // Private constructor
  EncryptDataService._internal();

  // Factory constructor to return the same instance
  factory EncryptDataService() {
    return _instance;
  }

  // Encryption key
  encrypt.Key? _key;
  // Encryption newKey
  encrypt.Key? _newKey;

  // Method to initialize the encryption key
  void init(String keyString) {
    _key = encrypt.Key.fromUtf8(keyString);
  }

  // Method to initialize the encryption new key
  void initNew(String keyString) {
    _newKey = encrypt.Key.fromUtf8(keyString);
  }

  // change the keys
  void reInit() {
    if ((_key == null) || (_newKey == null)) {
      throw Exception('ReEncryption keys are not initialized.');
    }
    else {
      _key = _newKey;
      _newKey = null;
    }
  }

  // Method to encrypt data
  String encryptData(String plainText) {
    if (_key == null) {
      throw Exception('Encryption key is not initialized.');
    }
    else {
      final iv = encrypt.IV.fromSecureRandom(16); // Generate a random IV
      final encrypter = encrypt.Encrypter(encrypt.AES(_key!, mode: encrypt.AESMode.cbc));

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      final ivBase64 = iv.base64;
      final encryptedBase64 = encrypted.base64;

      return '$ivBase64:$encryptedBase64'; // Store IV and ciphertext together
    }
  }

  // Method to decrypt data
  String decryptData(String encryptedData) {
    if (_key == null) {
      throw Exception('ReEncryption keys are not initialized.');
    }
    else {
      final parts = encryptedData.split(':');
      final iv = encrypt.IV.fromBase64(parts[0]); // Extract the IV
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

      final encrypter = encrypt.Encrypter(encrypt.AES(_key!, mode: encrypt.AESMode.cbc));
      String decrypted = '';
      try {
        decrypted = encrypter.decrypt(encrypted, iv: iv);
      }
      catch (e) {
        decrypted = "CRYPTO ERROR: $e";
      }
      return decrypted;
    }
  }

  // Method to re-encrypt data
  String reEncryptData(String encryptedData) {
    if ((_key == null) || (_newKey == null)) {
      throw Exception('ReEncryption keys are not initialized.');
    }
    else {
      final parts = encryptedData.split(':');
      final iv = encrypt.IV.fromBase64(parts[0]); // Extract the IV
      final ivBase64 = iv.base64;
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

      final encrypter = encrypt.Encrypter(encrypt.AES(_key!, mode: encrypt.AESMode.cbc));
      final reEncrypter = encrypt.Encrypter(encrypt.AES(_newKey!, mode: encrypt.AESMode.cbc));
      String reEncryptedBase64 = '';
      try {
        final decrypted = encrypter.decrypt(encrypted, iv: iv);
        final reEncrypted = reEncrypter.encrypt(decrypted, iv: iv);
        reEncryptedBase64 = reEncrypted.base64;
      }
      catch (e) {
        return "CRYPTO ERROR: $e";
      }
      return '$ivBase64:$reEncryptedBase64';
    }
  }
}