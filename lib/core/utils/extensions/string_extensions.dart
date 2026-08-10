// Extensions on String and String? for common utility operations.

extension StringX on String {
  /// Returns `true` if the string is empty after trimming whitespace.
  bool get isBlank => trim().isEmpty;

  /// Returns `true` if the string is non-empty after trimming whitespace.
  bool get isNotBlank => trim().isNotEmpty;

  /// Capitalizes the first character of the string.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncates the string to [maxLength] characters, appending [ellipsis] if
  /// the string was shortened.
  String truncate(int maxLength, {String ellipsis = '…'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }
}

extension NullableStringX on String? {
  /// Returns `true` when the string is null or blank.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// Returns the string or an empty string if null.
  String get orEmpty => this ?? '';
}
