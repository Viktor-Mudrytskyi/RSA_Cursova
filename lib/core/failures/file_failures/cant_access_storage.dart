import 'package:cursova/core/failures/file_failures/base_file_failure.dart';

class CantAccessStorage extends BaseFileFailure {
  @override
  String get message => 'Cant access storage';
}
