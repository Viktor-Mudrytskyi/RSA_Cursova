class ResponseWrapper<Success, Failure> {
  const ResponseWrapper({this.data, this.failure});

  final Success? data;
  final Failure? failure;

  void fold({
    required void Function(Success success) success,
    required void Function(Failure failure) failure,
  }) {
    if (isSuccessful) {
      success(this.data as Success);
    } else {
      failure(this.failure as Failure);
    }
  }

  bool get isSuccessful => data != null;
}
