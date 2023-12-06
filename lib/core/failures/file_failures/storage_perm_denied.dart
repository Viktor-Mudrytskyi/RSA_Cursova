import 'package:cursova/core/failures/file_failures/base_file_failure.dart';

class StoragePermanentlyDenied extends BaseFileFailure {
  @override
  String get message => 'Storage access is permanently denied';
}
