import 'dart:io';
import 'package:cursova/core/failures/file_failures/base_file_failure.dart';
import 'package:cursova/core/responses/response_wrapper.dart';
import 'package:flutter/foundation.dart';
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
    Uint8List bytes,
    String fileName,
    String fileExtension,
  ) async {
    BaseFileFailure? failure;
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

    final String newPath = '$path\\$fileName.$fileExtension';
    debugPrint('New path: $newPath');

    final newFile = File(newPath);
    await newFile.writeAsBytes(bytes);

    return ResponseWrapper(data: newFile);
  }
}
