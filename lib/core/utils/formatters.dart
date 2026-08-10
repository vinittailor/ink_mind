// Static formatting helpers used across the app.

class Formatters {
  Formatters._(); // prevent instantiation

  /// Formats a [DateTime] as `"Aug 3, 2026"`.
  static String dateShort(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Formats a [DateTime] as `"Aug 3, 2026 · 14:30"`.
  static String dateTimeFull(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${dateShort(date)} · $hour:$minute';
  }

  /// Returns a human-readable relative time string, e.g. `"2 hours ago"`.
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return dateShort(date);
  }
}
