// Static validation helpers used across the app.
//
// Returns an error string when validation fails, or null on success — the
// convention expected by TextFormField.validator.

class Validators {
  Validators._(); // prevent instantiation

  /// Returns an error message if [value] is null or blank, else `null`.
  static String? notEmpty(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty.';
    }
    return null;
  }

  /// Returns an error message if [value] is not a valid email, else `null`.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email cannot be empty.';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  /// Returns an error message if [value] is shorter than [minLength], else `null`.
  static String? minLength(String? value, int minLength, {String fieldName = 'Field'}) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters.';
    }
    return null;
  }
}
