import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormatter {
  static String getTimeAgo(Timestamp dateTime) {
    final difference = DateTime.now().difference(dateTime.toDate());
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
