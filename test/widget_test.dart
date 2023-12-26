// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'dart:typed_data';

import 'package:cursova/core/managers/file_saver_manager.dart';
import 'package:cursova/core/rsa/managers/rsa_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanodart/nanodart.dart';

void main() {
  test('Main', () async {
    WidgetsFlutterBinding.ensureInitialized();
    final filePath =
        r"C:\Users\mudri\Documents\Безымянный11.png".replaceAll(r'\', '/');
    final segments = filePath.split('/').last.split('.');
    final name = '${segments.first}_encrypted_decrypted.${segments.last}';

    final initialBytes = File(filePath).readAsBytesSync();
    final keys = await RSAmanager().generateKeys();
    final public = keys.publicKey;
    final private = keys.privateKey;
    final bigIntList = RSAmanager().readOriginalFile(initialBytes);
    final List<BigInt> encryptedBigIntList = [];
    final List<BigInt> decryptedBigIntList = [];
    final List<int> encryptedBytesList = [];
    List<int> decryptedBytesList = [];

    for (var i = 0; i < bigIntList.length; i++) {
      final initBigInt = bigIntList[i];
      expect(initBigInt < private.n, true);
      final encryptedBigInt = initBigInt.modPow(public.a, public.n);
      final decryptedBigInt = encryptedBigInt.modPow(private.b, private.n);
      expect(initBigInt == decryptedBigInt, true);
      encryptedBigIntList.add(encryptedBigInt);
      decryptedBigIntList.add(decryptedBigInt);
    }

    for (var i = 0; i < decryptedBigIntList.length; i++) {
      final current = NanoHelpers.bigIntToBytes(decryptedBigIntList[i]);
      for (var i = 0; i < RSAmanager.byteChunk - current.length; i++) {
        decryptedBytesList.add(0);
      }
      decryptedBytesList.addAll(current);
    }
    decryptedBytesList = decryptedBytesList.reversed.toList();

    for (var i = 0; i < initialBytes.length; i++) {
      expect(decryptedBytesList[i] == initialBytes[i], true);
    }
    // expect(listEquals(initialBytes, decryptedBytesList), true);

    File("C:/Users/mudri/Documents/$name").writeAsBytesSync(decryptedBytesList);
  });

  // test('File reading', () async {
  //   final filePath =
  //       r"C:\Users\mudri\Documents\i_am_clown.txt".replaceAll(r'\', '/');
  //   final initialBytes = [0, 0, 0, 0, 0, 0, 0, 1];
  //   final bigIntList =
  //       RSAmanager().readOriginalFile(Uint8List.fromList(initialBytes));
  //   // final initialBytes = File(filePath).readAsBytesSync();
  //   // final bigIntList = RSAmanager().readOriginalFile(initialBytes);
  //   var bytes = <int>[];
  //   for (var i = 0; i < bigIntList.length; i++) {
  //     var b = NanoHelpers.bigIntToBytes(bigIntList[i]).map((e) => e).toList();

  //     for (var i = 0; i < RSAmanager.byteChunk - b.length; i++) {
  //       b.add(0);
  //     }
  //     bytes.addAll(b);
  //   }
  //   // expect(listEquals(bytes, initialBytes), true);
  // });
}
