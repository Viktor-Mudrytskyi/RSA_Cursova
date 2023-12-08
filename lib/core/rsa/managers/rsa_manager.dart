import 'dart:async';
import 'dart:math';
import 'package:cursova/core/rsa/euclid_response.dart';
import 'package:cursova/core/rsa/rsa_key_pair.dart';
import 'package:flutter/foundation.dart';
import 'package:nanodart/nanodart.dart';
import 'package:ninja_prime/ninja_prime.dart';

class RSAmanager {
  static RSAmanager? _instance;

  factory RSAmanager() {
    _instance ??= RSAmanager._internal();
    return _instance!;
  }
  RSAmanager._internal();

  Future<Uint8List> cypherBytes(Uint8List bytes, RSAPublicKey keys) async {
    final encryptedBytes = await compute(
      (message) async {
        String bytesString = '';
        for (var e in bytes) {
          bytesString += e.toString();
        }

        final bigIntBytes = BigInt.parse(bytesString);
        final encryptedBigIntBytes = bigIntBytes.modPow(keys.a, keys.n);
        final encryptedBytes = NanoHelpers.bigIntToBytes(encryptedBigIntBytes);

        return encryptedBytes;
      },
      'Encryption',
    );
    return encryptedBytes;
  }

  Future<Uint8List> decipherBytes(Uint8List bytes, RSAPrivateKey keys) async {
    final decryptedBytes = await compute(
      (message) {
        String bytesString = '';
        for (var e in bytes) {
          bytesString += e.toString();
        }

        final bigIntBytes = BigInt.parse(bytesString);
        final decrypteddBigIntBytes = bigIntBytes.modPow(keys.b, keys.n);
        final decryptedBytes = NanoHelpers.bigIntToBytes(decrypteddBigIntBytes);
        return decryptedBytes;
      },
      'Decryption',
    );
    return decryptedBytes;
  }

  Future<RSAKeyPair> generateKeys() async {
    final keys = await compute<String, RSAKeyPair>(
      (message) {
        final p = randomPrimeBigInt(1024);
        // final p = BigInt.from(11);
        final q = randomPrimeBigInt(1024);
        // final q = BigInt.from(5);
        debugPrint('P = $p');
        debugPrint('Q = $q');
        final n = p * q;
        debugPrint('n = $n');

        final phi = _calcPhiSync(p, q);
        debugPrint('Phi: $phi');

        final a = _choosePublicGCDsync(phi);
        // final a = BigInt.from(7);
        debugPrint('A = $a');

        final b = _choosePrivateGCDsync(phi, a);
        debugPrint('B = $b');

        return RSAKeyPair(
          privateKey: RSAPrivateKey(b: b, p: p, q: q, n: n),
          publicKey: RSAPublicKey(a: a, n: n),
        );
      },
      'KeyGeneration',
    );
    return keys;
  }

  BigInt _calcPhiSync(BigInt p, BigInt q) {
    return (q - BigInt.one) * (p - BigInt.one);
  }

  BigInt _choosePublicGCDsync(BigInt phi) {
    while (true) {
      final randBigInt = randomBigInt(2048);
      if (randBigInt.gcd(phi) == BigInt.one && randBigInt < phi) {
        return randBigInt;
      }
    }
  }

  BigInt _choosePrivateGCDsync(BigInt phi, BigInt a) {
    final euclid = _extendedEuclidean(a, phi);
    return phi + euclid.x;
  }

  ExtendedEuclideanResult _extendedEuclidean(BigInt a, BigInt b) {
    if (b == BigInt.zero) {
      return ExtendedEuclideanResult(a, BigInt.one, BigInt.zero);
    } else {
      ExtendedEuclideanResult previousResult = _extendedEuclidean(b, a % b);
      BigInt gcd = previousResult.gcd;
      BigInt x = previousResult.y;
      BigInt y = previousResult.x - (a ~/ b) * previousResult.y;
      return ExtendedEuclideanResult(gcd, x, y);
    }
  }
}
