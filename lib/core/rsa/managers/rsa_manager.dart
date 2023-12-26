import 'dart:async';
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

  static final BigInt const2047 = BigInt.from(2).pow(2047);
  static final BigInt maxKeyPossible = BigInt.from(2).pow(2048) - BigInt.one;
  static const byteChunk = 190;

  Future<Uint8List> encryptBytes(Uint8List bytes, RSAPublicKey keys) async {
    final encryptedBytes = await compute(
      (message) {
        final cluster256List = bytesToBigIntList(bytes);
        List<int> encryptedBytes = [];
        for (var e in cluster256List) {
          var encryptedBigInt = e.modPow(keys.a, keys.n);
          final chunk = NanoHelpers.bigIntToBytes(encryptedBigInt);
          final buffer = <int>[];

          for (var i = 0; i < byteChunk - chunk.length; i++) {
            buffer.add(0);
          }
          buffer.addAll(chunk);
          encryptedBytes.addAll(buffer);
        }

        return Uint8List.fromList(encryptedBytes);
      },
      'Encryption',
    );
    return encryptedBytes;
  }

  List<BigInt> bytesToBigIntList(Uint8List bytes) {
    final isModulus = bytes.length % byteChunk == 0;
    final listLength = bytes.length ~/ byteChunk + ((isModulus) ? 0 : 1);
    final bigIntegerList = <BigInt>[];

    for (var i = 0; i < listLength; i++) {
      var tempBigInt = BigInt.zero;

      for (var j = 0; j < byteChunk; j++) {
        if ((i * byteChunk + j) < bytes.length) {
          tempBigInt = tempBigInt << 8;
          tempBigInt += BigInt.from(bytes[i * byteChunk + j]);
        }
      }

      bigIntegerList.add(tempBigInt);
    }
    return bigIntegerList;
  }

  Future<Uint8List> decryptBytes(Uint8List bytes, RSAPrivateKey keys) async {
    final decryptedBytes = await compute(
      (message) {
        final cluster256List = bytesToBigIntList(bytes);
        List<int> decryptedBytes = [];

        for (var e in cluster256List) {
          final decryptedBigIntBytes = e.modPow(keys.b, keys.n);
          final chunk = NanoHelpers.bigIntToBytes(decryptedBigIntBytes);
          // final buffer = <int>[];

          // for (var i = 0; i < byteChunk - chunk.length; i++) {
          //   buffer.add(0);
          // }
          // buffer.addAll(chunk);
          decryptedBytes.addAll(chunk);
        }

        return Uint8List.fromList(decryptedBytes);
      },
      'Decryption',
    );
    return decryptedBytes;
  }

  Future<RSAKeyPair> generateKeys() async {
    final keys = await compute<String, RSAKeyPair>(
      (message) {
        do {
          final p = randomPrimeBigInt(1024);
          final q = randomPrimeBigInt(1024);
          debugPrint('P = $p');
          debugPrint('Q = $q');
          final n = p * q;
          debugPrint('n = $n');

          final phi = _calcPhiSync(p, q);
          debugPrint('Phi: $phi');

          final a = _choosePublicGCDsync(phi);
          debugPrint('A = $a');

          final b = _choosePrivateGCDsync(phi, a);
          debugPrint('B = $b');

          if (n > const2047) {
            return RSAKeyPair(
              privateKey: RSAPrivateKey(b: b, p: p, q: q, n: n),
              publicKey: RSAPublicKey(a: a, n: n),
            );
          }
        } while (true);
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
      final randBigInt = randomBigInt(2000);
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
