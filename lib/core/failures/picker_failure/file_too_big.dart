import 'package:cursova/core/failures/picker_failure/base_picker_failure.dart';

class FileTooBigFailure extends BaseFilePickerFailure {
  @override
  String get message => 'File too big';
}
