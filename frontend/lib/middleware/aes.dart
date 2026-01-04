import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:password_generator/middleware/rsa.dart';


/// Decrypts AES-GCM.
///
/// - keyBytes: 32-byte key
/// - nonce: 12-byte nonce
/// - combinedCiphertext: ciphertext || tag (if you have separate tag, pass separately)
Future<String> aesGcmDecrypt({
  required String key,
  required String combinedCiphertextB64, // ciphertext + 16-byte tag
}) async {

  // Decode all base64 inputs
  final encryptedkeyBytes = base64.decode(key);
  final String combinedB64 = utf8.decode(base64.decode(combinedCiphertextB64));

  final keyBytes = rsaOaepDecrypt(encryptedkeyBytes);


  // Split ciphertext and tag and iv (last 12 bytes are b64IV last 16 bytes is GCM tag)
  const tagLength = 16;
  const ivLength = 12;

  if (combinedB64.length < (ivLength + tagLength + 1)) {
    throw ArgumentError('Ciphertext too short to contain GCM tag.');
  }
  final combinedArray = combinedB64.split(":");
  final combined = base64.decode(combinedArray[0]);

  final ivBytes = base64.decode(combinedArray[1]);


  final cipherText = combined.sublist(0, combined.length - tagLength);
  final tag = combined.sublist(combined.length - tagLength);

  // Prepare algorithm & key
  final algorithm = AesGcm.with256bits();
  final secretKey = SecretKey(await keyBytes);

  // Create a SecretBox from the decoded values
  final secretBox = SecretBox(
    cipherText,
    nonce: ivBytes,
    mac: Mac(tag),
  );

  // Decrypt
  final clearBytes = await algorithm.decrypt(
    secretBox,
    secretKey: secretKey,
  );

  return utf8.decode(clearBytes);
}