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

  static final BigInt const2048 = BigInt.from(2).pow(2048);

  Future<Uint8List> cypherBytes(Uint8List bytes, RSAPublicKey keys) async {
    final encryptedBytes = await compute(
      (message) {
        final cluster256List = _readBytes(bytes);
        // final cluster256List = [BigInt.one];
        List<int> encryptedBytes = [];
        for (var e in cluster256List) {
          var encryptedBigInt = e.modPow(keys.a, keys.n);
          final chunk = NanoHelpers.bigIntToBytes(encryptedBigInt);
          print('Encrypted bits: ${encryptedBigInt.toRadixString(2)}');
          print(' Length: ${encryptedBigInt.toRadixString(2).length}');
          encryptedBytes.addAll(chunk);
        }

        return Uint8List.fromList(encryptedBytes);
      },
      'Encryption',
    );
    return encryptedBytes;
  }

  List<BigInt> _readBytes(Uint8List bytes) {
    final isModulus = bytes.length % 256 == 0;
    final listLength = bytes.length ~/ 256 + ((isModulus) ? 0 : 1);
    final bigIntegerList = <BigInt>[];

    for (var i = 0; i < listLength; i++) {
      var tempBigInt = BigInt.zero;

      for (var j = 0; j < 256; j++) {
        tempBigInt = tempBigInt << 8;
        if (!(i * 256 + j >= bytes.length)) {
          tempBigInt += BigInt.from(bytes[i * 256 + j]);
        }
      }

      bigIntegerList.add(tempBigInt);
    }
    print('Read bits: ${bigIntegerList.first.toRadixString(2)}');
    print('Length: ${bigIntegerList.first.toRadixString(2).length}');
    return bigIntegerList;
  }

  Future<Uint8List> decipherBytes(Uint8List bytes, RSAPrivateKey keys) async {
    final decryptedBytes = await compute(
      (message) {
        final cluster256List = _readBytes(bytes);
        List<int> decryptedBytes = [];

        for (var e in cluster256List) {
          final decryptedBigIntBytes = e.modPow(keys.b, keys.n);

          final chunk = NanoHelpers.bigIntToBytes(decryptedBigIntBytes);
          print('Decrypted bits: ${decryptedBigIntBytes.toRadixString(2)}');
          print('Length: ${decryptedBigIntBytes.toRadixString(2).length}');

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
        final p = randomPrimeBigInt(1024);
        // final p = BigInt.from(101);
        final q = randomPrimeBigInt(1024);
        // final q = BigInt.from(113);
        debugPrint('P = $p');
        debugPrint('Q = $q');
        final n = p * q;
        debugPrint('n = $n');

        final phi = _calcPhiSync(p, q);
        debugPrint('Phi: $phi');

        final a = _choosePublicGCDsync(phi);
        // final a = BigInt.from(3533);
        debugPrint('A = $a');

        final b = _choosePrivateGCDsync(phi, a);
        debugPrint('B = $b');

        final encryptedBigIntBytes = BigInt.from(4923).modPow(a, n);
        print('!!!!!!!$encryptedBigIntBytes');

        final decryptedBigIntBytes = encryptedBigIntBytes.modPow(b, n);
        print('!!!!!!!$decryptedBigIntBytes');

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
