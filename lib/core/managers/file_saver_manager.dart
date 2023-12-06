// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cursova/core/failures/file_failures/base_file_failure.dart';

import 'package:cursova/core/responses/response_wrapper.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileSaverManager {
  static FileSaverManager? _instance;

  factory FileSaverManager() {
    _instance ??= FileSaverManager._internal();
    return _instance!;
  }

  FileSaverManager._internal();

  Future<ResponseWrapper<String, BaseFileFailure>>
      getDownloadFolderPath() async {
    Directory directory;
    if (Platform.isAndroid) {
      directory = Directory("/storage/emulated/0/Download");
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final exPath = directory.path;
    await Directory(exPath).create(recursive: true);
    return ResponseWrapper(data: exPath);
  }

  Future<ResponseWrapper<File, BaseFileFailure>> writeToDownloadFolder(
      PlatformFile file) async {
    BaseFileFailure? failure;
    File? writtenFile;
    final downloadPathResponse =
        await FileSaverManager().getDownloadFolderPath();
    String? path;
    downloadPathResponse.fold(
      success: (data) => path = data,
      failure: (f) => failure = f,
    );

    if (failure != null) {
      return ResponseWrapper(failure: failure);
    }

    final KeyPair result = await RSA.generate(2048);
    final t = await RSA.encryptOAEPBytes(
      file.bytes!,
      'test',
      Hash.SHA256,
      result.publicKey,
    );
    final String newPath = '$path/${file.name}_crypted.${file.extension}';
    print('New path: $newPath');
    final fileEncrypted = File(newPath);
    await fileEncrypted.writeAsBytes(t);
    writtenFile = fileEncrypted;
    print('Successful crypt');
    return ResponseWrapper(data: writtenFile);
  }
}
