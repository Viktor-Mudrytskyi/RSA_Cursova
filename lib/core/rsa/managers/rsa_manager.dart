// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';
import 'package:cursova/core/rsa/euclid_response.dart';
import 'package:cursova/core/rsa/rsa_key_pair.dart';
import 'package:flutter/foundation.dart';
import 'package:ninja_prime/ninja_prime.dart';

class RSAmanager {
  static RSAmanager? _instance;

  factory RSAmanager() {
    _instance ??= RSAmanager._internal();
    return _instance!;
  }
  RSAmanager._internal();

  Future<RSAKeyPair> generateKeys() async {
    final keys = await compute<String, RSAKeyPair>(
      (message) {
        final p = randomPrimeBigInt(2048);
        final q = randomPrimeBigInt(2048);
        print('P = $p');
        print('Q = $q');
        final n = p * q;
        print('n = $n');

        final phi = _calcPhiSync(p, q);
        print('Phi: $phi');

        final a = _choosePublicGCDsync(phi);
        print('A = $a');

        final b = _choosePrivateGCDsync(phi);
        print('B = $b');

        return RSAKeyPair(n, p, q);
      },
      'KeyGeneration',
    );
    return keys;
  }

  BigInt _calcPhiSync(BigInt p, BigInt q) {
    return (q - BigInt.one) * (p - BigInt.one);
  }

  BigInt _choosePublicGCDsync(BigInt phi) {
    bool hasMatch = false;
    final rand = Random();
    while (!hasMatch) {
      final randBigInt = randomBigInt(rand.nextInt(phi.bitLength - 2) + 1);
      if (randBigInt.gcd(phi) == BigInt.one) {
        hasMatch = true;
        return randBigInt;
      }
    }
    throw Exception('No nuber');
  }

  BigInt _choosePrivateGCDsync(BigInt phi, BigInt a) {
    final euclid = _extendedEuclidean(a, phi);
    throw Exception('No nuber');
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
