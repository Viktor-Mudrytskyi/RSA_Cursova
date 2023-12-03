import 'package:cursova/core/failures/picker_failure/base_picker_failure.dart';

class FileNotPickedFailure extends BaseFilePickerFailure {
  @override
  String get message => 'File was not picked';
}
