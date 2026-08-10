// App-wide constants for InkMind.
//
// All magic strings and numbers live here. Feature code should import
// from this file rather than hard-coding values inline.

class AppConstants {
  AppConstants._(); // prevent instantiation

  // ── Gemini API ─────────────────────────────────────────────────────────────
  /// Base URL for the Gemini REST API.
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/';

  // ── Networking ──────────────────────────────────────────────────────────────
  /// Default connection timeout in milliseconds.
  static const int connectTimeoutMs = 15000;

  /// Default receive timeout in milliseconds.
  static const int receiveTimeoutMs = 30000;

  // ── Local database ──────────────────────────────────────────────────────────
  /// SQLite database filename.
  static const String dbName = 'ink_mind.db';

  /// Current database schema version.
  static const int dbVersion = 2;

  // ── Shared Preferences / cache keys ─────────────────────────────────────────
  static const String prefKeyOnboardingDone = 'onboarding_done';
}
