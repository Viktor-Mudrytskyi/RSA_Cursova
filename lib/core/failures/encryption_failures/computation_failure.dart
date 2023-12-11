import 'package:cursova/core/failures/encryption_failures/base_encryption_failure.dart';

class ComputationFailure extends BaseEncryptionFailure {
  @override
  String get message => 'Computation failure';
}
