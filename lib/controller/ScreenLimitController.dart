import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class ScreenLimitController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ حفظ الحد اليومي في Firebase
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
      print("✅ تم حفظ الحد اليومي بنجاح");
    } catch (e) {
      print("❌ خطأ في حفظ الحد اليومي: $e");
    }
  }

  /// ✅ استرجاع الحد اليومي للطفل
  Future<Map<String, dynamic>?> getUsageLimit(String parentId, String childId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('Parent').doc(parentId).collection('Children').doc(childId).get();

      if (!snapshot.exists || snapshot.data()?['usageLimit'] == null) {
        print("❌ لا يوجد بيانات للحد اليومي لهذا الطفل.");
        return null;
      }

      return snapshot.data()?['usageLimit'];
    } catch (e) {
      print("❌ خطأ في جلب الحد اليومي: $e");
      return null;
    }
  }

  /// ✅ التحقق مما إذا كان الطفل يمكنه استخدام التطبيق
  Future<bool> isUsageAllowed(String parentId, String childId) async {
    try {
      Map<String, dynamic>? usageLimit = await getUsageLimit(parentId, childId);
      if (usageLimit == null) return true; // السماح إذا لم يكن هناك حد زمني

      DateTime now = DateTime.now();
      DateFormat format = DateFormat("HH:mm");

      DateTime start = format.parse(usageLimit['startTime']);
      DateTime end = format.parse(usageLimit['endTime']);

      return now.isAfter(start) && now.isBefore(end);
    } catch (e) {
      print("❌ خطأ في التحقق من الحد اليومي: $e");
      return true;
    }
  }

  /// ✅ حذف الحد الزمني بالكامل من Firebase
  Future<void> deleteUsageLimit(String parentId, String childId) async {
    try {
      await _firestore.collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(childId)
          .update({'usageLimit': FieldValue.delete()});

      print("✅ تم حذف الحد الزمني بنجاح");
    } catch (e) {
      print("❌ خطأ في حذف الحد الزمني: $e");
    }
  }
}