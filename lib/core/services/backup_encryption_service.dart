import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class BackupEncryptionService {
  static const String _magicPrefix = "TLBACKUP:";

  /// Encrypts the plain text using a password-derived key.
  /// Returns a Base64 encoded string containing IV + Encrypted Data.
  static String encryptData(String plainText, String password) {
    // 1. Derive a 32-byte key from the password using SHA-256
    final keyBytes = sha256.convert(utf8.encode(password)).bytes;
    final key = encrypt.Key(Uint8List.fromList(keyBytes));

    // 2. Generate a random IV (Initialization Vector)
    final iv = encrypt.IV.fromLength(16);

    // 3. Encrypt using AES-CBC
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    // Add magic prefix for integrity check on decryption
    final dataToEncrypt = "$_magicPrefix$plainText";
    final encrypted = encrypter.encrypt(dataToEncrypt, iv: iv);

    // 4. Combine IV and Encrypted Data (so we know IV for decryption)
    // Format: IV_BASE64:ENCRYPTED_BASE64
    return "${iv.base64}:${encrypted.base64}";
  }

  /// Decrypts the encrypted text using the password.
  /// Expects format: IV_BASE64:ENCRYPTED_BASE64
  static String decryptData(String encryptedFull, String password) {
    try {
      // 1. Split IV and Encrypted Data
      final parts = encryptedFull.split(':');
      if (parts.length != 2) throw Exception("Invalid backup format");

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedData = encrypt.Encrypted.fromBase64(parts[1]);

      // 2. Derive Key
      final keyBytes = sha256.convert(utf8.encode(password)).bytes;
      final key = encrypt.Key(Uint8List.fromList(keyBytes));

      // 3. Decrypt
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decrypted = encrypter.decrypt(encryptedData, iv: iv);

      // 4. Integrity Check
      if (!decrypted.startsWith(_magicPrefix)) {
        throw Exception("Incorrect password or corrupted file signature.");
      }

      return decrypted.substring(_magicPrefix.length);
    } catch (e) {
      throw Exception(
          "Decryption failed. Incorrect password or corrupted file.");
    }
  }
}
