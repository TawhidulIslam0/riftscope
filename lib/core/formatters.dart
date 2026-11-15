String duration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

String timeAgo(int timestamp) {
  final difference = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
  if (difference.inDays > 0) return '${difference.inDays}d ago';
  if (difference.inHours > 0) return '${difference.inHours}h ago';
  if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
  return 'Just now';
}

String safeString(dynamic value, [String fallback = '—']) =>
    value == null ? fallback : value.toString();
