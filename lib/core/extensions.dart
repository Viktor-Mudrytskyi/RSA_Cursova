extension EmptyCheck on List<dynamic>? {
  bool get isNullOrEmpty => (this ?? []).isEmpty;
}
