import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScreenLimitController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // save daily usage limit to Firestore
  Future<void> saveUsageLimit({
    required String parentId,
    required String childId,
    required String startTime,
    required String endTime,
  }) async {
    try {
      await _firestore.collection('Parent').doc(parentId).collection('Children').doc(childId).update({
        'usageLimit': {
          'startTime': startTime,
          'endTime': endTime,
        }
      });
      print("Daily limit saved");
    } catch (e) {
      print("Error saving limit: $e");
    }
  }

  // get usage limit for specific child
  Future<Map<String, dynamic>?> getUsageLimit(String parentId, String childId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('Parent').doc(parentId).collection('Children').doc(childId).get();

      if (!snapshot.exists || snapshot.data()?['usageLimit'] == null) {
        print(" No usage limit found.");
        return null;
      }

      return snapshot.data()?['usageLimit'];
    } catch (e) {
      print(" Error fetching usage limit: $e");
      return null;
    }
  }

  // check if child is allowed to use the app at current time
  Future<bool> isUsageAllowed(String parentId, String childId) async {
    try {
      Map<String, dynamic>? usageLimit = await getUsageLimit(parentId, childId);
      if (usageLimit == null) return true;

      DateTime now = DateTime.now();
      DateFormat format = DateFormat("HH:mm");

      DateTime start = format.parse(usageLimit['startTime']);
      DateTime end = format.parse(usageLimit['endTime']);

      return now.isAfter(start) && now.isBefore(end);
    } catch (e) {
      print(" Error checking usage time: $e");
      return true;
    }
  }

  // remove usage limit from Firestore
  Future<void> deleteUsageLimit(String parentId, String childId) async {
    try {
      await _firestore.collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(childId)
          .update({'usageLimit': FieldValue.delete()});

      print(" Usage limit deleted");
    } catch (e) {
      print(" Error deleting usage limit: $e");
    }
  }

  // calculate time difference between start and end time
  String calculateDuration(String start, String end) {
    final startParts = start.split(":").map(int.parse).toList();
    final endParts = end.split(":").map(int.parse).toList();

    final startMinutes = startParts[0] * 60 + startParts[1];
    final endMinutes = endParts[0] * 60 + endParts[1];

    int durationMinutes;
    if (endMinutes >= startMinutes) {
      durationMinutes = endMinutes - startMinutes;
    } else {
      durationMinutes = (24 * 60 - startMinutes) + endMinutes;
    }

    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (minutes == 0) {
      return "$hours ساعة";
    } else {
      return "$hours ساعة و $minutes دقيقة";
    }
  }
}
