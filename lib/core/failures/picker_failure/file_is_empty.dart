import 'package:cursova/core/failures/picker_failure/base_picker_failure.dart';

class FileIsEmptyFailure extends BaseFilePickerFailure {
  @override
  String get message => 'File is empty';
}
