abstract class BaseFailure {
  String get message;
  @override
  String toString() {
    return message;
  }
}
