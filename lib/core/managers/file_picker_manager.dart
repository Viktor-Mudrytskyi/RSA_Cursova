import 'package:cursova/core/extensions.dart';
import 'package:cursova/core/failures/picker_failure/base_picker_failure.dart';
import 'package:cursova/core/failures/picker_failure/file_is_empty.dart';
import 'package:cursova/core/failures/picker_failure/file_not_picked.dart';
import 'package:cursova/core/failures/picker_failure/file_too_big.dart';
import 'package:cursova/core/responses/response_wrapper.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerManager {
  late final FilePicker _filePicker;
  static FilePickerManager? _instance;

  factory FilePickerManager() {
    _instance ??= FilePickerManager._internal(FilePicker.platform);
    return _instance!;
  }

  FilePickerManager._internal(FilePicker filePicker) : _filePicker = filePicker;

  Future<ResponseWrapper<PlatformFile, BaseFilePickerFailure>>
      pickFileAsBYtes() async {
    final file = await _filePicker.pickFiles(
      allowMultiple: false,
      type: FileType.any,
      withData: true,
    );
    if (file == null) {
      return ResponseWrapper(failure: FileNotPickedFailure());
    }
    if (file.files.isEmpty) {
      return ResponseWrapper(failure: FileIsEmptyFailure());
    }

    if (file.files.first.bytes.isNullOrEmpty) {
      return ResponseWrapper(failure: FileIsEmptyFailure());
    }

    if (file.files.first.bytes!.length > 1000000) {
      return ResponseWrapper(failure: FileTooBigFailure());
    }

    return ResponseWrapper(data: file.files.first);
  }
}
