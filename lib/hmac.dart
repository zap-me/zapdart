import 'dart:convert';
import 'package:crypto/crypto.dart';

String createHmacSig(String secret, String message) {
  var secretBytes = utf8.encode(secret);
  var messageBytes = utf8.encode(message);
  var hmac = Hmac(sha256, secretBytes);
  var digest = hmac.convert(messageBytes);
  return base64.encode(digest.bytes);
}

class NoApiKeyException implements Exception {}

void checkApiKey(String? apikey, String? apisecret) {
  if (apikey == null) throw NoApiKeyException();
  if (apisecret == null) throw NoApiKeyException();
}
