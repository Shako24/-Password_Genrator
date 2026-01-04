import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

///////////////////////////////////////////////////////
// Server Side RSA Encryption For Save Travel of Information
///////////////////////////////////////////////////////

/// Parse PEM (PKCS#1 or PKCS#8) to RSAPublicKey using basic_utils
RSAPublicKey parsePublicKeyFromPem(String pem) {
  final publicKey = CryptoUtils.rsaPublicKeyFromPem(pem);
  return RSAPublicKey((publicKey).modulus!, publicKey.exponent!);
}

/// Get the saved PEM public key from SharedPreferences
Future<String?> getPublicKeyPem() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('server_public_key');
}

/// Encrypts plainText with RSA OAEP SHA-256 using the stored PEM public key
Future<String> rsaOaepEncrypt(String plainText) async {
  final pem = await getPublicKeyPem();
  if (pem == null) {
    throw StateError('No public key found in SharedPreferences');
  }

  // Parse PEM into RSAPublicKey
  final rsaPub = CryptoUtils.rsaPublicKeyFromPem(pem);

  // Convert String → bytes
  final data = Uint8List.fromList(utf8.encode(plainText));

  // OAEP with SHA-256 for both hash & MGF1
  final oaep = OAEPEncoding(RSAEngine(), SHA256Digest(), SHA256Digest(), null);
  oaep.init(true, PublicKeyParameter<RSAPublicKey>(rsaPub));

  final inputLen = data.length;
  final output = <int>[];
  final blockSize = oaep.inputBlockSize;

  for (var offset = 0; offset < inputLen; offset += blockSize) {
    final len = (offset + blockSize > inputLen) ? inputLen - offset : blockSize;
    final chunk = data.sublist(offset, offset + len);
    final enc = oaep.process(chunk);
    output.addAll(enc);
  }

  // Return Base64 encoded ciphertext
  return base64.encode(Uint8List.fromList(output));
}

Future<void> savePublicKey(String pem) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('server_public_key', pem);
}


///////////////////////////////////////////////////////
// Client Side RSA Functions For Password Decryption
///////////////////////////////////////////////////////

const storage = FlutterSecureStorage();

/// Generates a strong RSA key pair (default 4096 bits) and encodes them in PKCS#8 (private) & X.509 (public).
Future<Map<String, String>> generateSecureRsaKeyPair({int bitLength = 4096}) async {
  final keyParams = RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64);
  final secureRandom = FortunaRandom();

  // Seed secure random with OS randomness
  final random = Random.secure();
  final seed = List<int>.generate(32, (_) => random.nextInt(256));
  secureRandom.seed(KeyParameter(Uint8List.fromList(seed)));

  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(keyParams, secureRandom));

  final pair = keyGen.generateKeyPair();
  final privateKey = pair.privateKey as RSAPrivateKey;
  final publicKey = pair.publicKey as RSAPublicKey;

  // PKCS#8 (private) & X.509 (public)
  final privatePem = CryptoUtils.encodeRSAPrivateKeyToPem(privateKey); // PKCS#8
  final publicPem = CryptoUtils.encodeRSAPublicKeyToPem(publicKey);    // X.509/SPKI

  await savePrivateKeyPem(privatePem); // Save private Key to secure Storage

  return {
    'publicKey': publicPem,
  };
}

/// Sve Private Key into Secure Storage
Future<void> savePrivateKeyPem(String pem) async {
  await storage.write(key: 'private_key_pem', value: pem);
}

Future<RSAPrivateKey?> getPrivateKeyFromStorage() async {
  final pem = await storage.read(key: 'private_key_pem');
  if (pem == null) {
    print('No private key found in storage.');
    return null;
  }

  // Parse PEM into RSAPrivateKey
  final pk = CryptoUtils.rsaPrivateKeyFromPem(pem);
  return RSAPrivateKey(pk.modulus!, pk.privateExponent!, pk.p, pk.q);
}

/// Parse PEM (PKCS#1 or PKCS#8) into RSAPrivateKey
RSAPrivateKey parsePrivateKeyFromPem(String pem) {
  final pk = CryptoUtils.rsaPrivateKeyFromPem(pem);
  return RSAPrivateKey(pk.modulus!, pk.privateExponent!, pk.p, pk.q);
}

/// Decrypt with RSA OAEP (SHA-256)
Future<Uint8List> rsaOaepDecrypt(Uint8List encrypted) async {

  final RSAPrivateKey? privateKey = await getPrivateKeyFromStorage();

  final oaep = OAEPEncoding(RSAEngine(), SHA256Digest() as Uint8List?, SHA256Digest(), null);
  oaep.init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey as PrivateKey)); // false = decrypt

  final inputLen = encrypted.length;
  final output = <int>[];
  final blockSize = oaep.inputBlockSize;

  for (var offset = 0; offset < inputLen; offset += blockSize) {
    final len = (offset + blockSize > inputLen) ? inputLen - offset : blockSize;
    final chunk = encrypted.sublist(offset, offset + len);
    final dec = oaep.process(chunk);
    output.addAll(dec);
  }
  return Uint8List.fromList(output);
}
