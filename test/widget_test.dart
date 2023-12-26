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
  test('Counter increments smoke test', () async {
    WidgetsFlutterBinding.ensureInitialized();

    final initialBytes = File(
            r"C:\Users\mudri\Documents\GreeceRomePolitics.pptx"
                .replaceAll(r'\', '/'))
        .readAsBytesSync();
    final keys = await RSAmanager().generateKeys();
    final public = keys.publicKey;
    final private = keys.privateKey;
    final bigIntList = RSAmanager().bytesToBigIntList(initialBytes);
    final List<BigInt> encryptedBigIntList = [];
    final List<BigInt> decryptedBigIntList = [];
    final List<int> encryptedBytesList = [];

    for (var i = 0; i < bigIntList.length; i++) {
      final initBigInt = bigIntList[i];

      expect(initBigInt < private.n, true);

      final encryptedBigInt = initBigInt.modPow(public.a, public.n);
      final decryptedBigInt = encryptedBigInt.modPow(private.b, private.n);
      // print('Initial Bytes Chunk: ${NanoHelpers.bigIntToBytes(initBigInt)}\n');
      print(
          'Encrypted Chunk: ${NanoHelpers.bigIntToBytes(encryptedBigInt)}\n\n');
      // print('Decrypted Bytes: ${NanoHelpers.bigIntToBytes(decryptedBigInt)}\n');

      expect(initBigInt == decryptedBigInt, true);

      encryptedBigIntList.add(encryptedBigInt);
      decryptedBigIntList.add(decryptedBigInt);
    }
    final decryptedBytes = <int>[];
    for (var i = 0; i < decryptedBigIntList.length; i++) {
      final b = NanoHelpers.bigIntToBytes(decryptedBigIntList[i]);
      decryptedBytes.addAll(b);
    }
    File("C:/Users/mudri/Documents/hampster_decrypted.jpg")
        .writeAsBytesSync(decryptedBytes);

    // for (var i = 0; i < encryptedBigIntList.length; i++) {
    //   final chunk = NanoHelpers.bigIntToBytes(encryptedBigIntList[i]);
    //   final buffer = <int>[];
    //   buffer.addAll(chunk);
    //   for (var i = 0; i < RSAmanager.byteChunk - chunk.length; i++) {
    //     buffer.add(0);
    //   }

    //   encryptedBytesList.addAll(buffer);
    // }

    // final newEncryptedBigIntList =
    //     RSAmanager().bytesToBigIntList(Uint8List.fromList(encryptedBytesList));
    // for (var i = 0; i < newEncryptedBigIntList.length; i++) {
    //   final initBigInt = bigIntList[i];
    //   final decryptedBigInt =
    //       newEncryptedBigIntList[i].modPow(private.b, private.n);

    //   expect(initBigInt == decryptedBigInt, true);
    // }
  });
}
