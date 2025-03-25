import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/child_model.dart';

class ChildController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Future<void> updateChildInfo(Child child, Function(Child) onUpdate) async {
  try {
    // إنشاء Map للتحديث
    Map<String, dynamic> updateData = {
      'name': child.name,
      'age': child.age,
      'photoUrl': child.photoUrl,
      'gender': child.gender,
      'parentId': child.parentId,
    };

    // التحديث في Firestore
    await _firestore
        .collection('Parent')
        .doc(child.parentId)
        .collection('Children')
        .doc(child.id)
        .set(updateData, SetOptions(merge: true));

    debugPrint("✅ تم تحديث البيانات في Firebase: ${child.name}, ${child.age}");

    // جلب البيانات المحدثة للتأكد من التحديث
    DocumentSnapshot updatedDoc = await _firestore
        .collection('Parent')
        .doc(child.parentId)
        .collection('Children')
        .doc(child.id)
        .get();

    if (updatedDoc.exists) {
      Child updatedChild = Child.fromMap(
        updatedDoc.id,
        updatedDoc.data() as Map<String, dynamic>,
      );
      onUpdate(updatedChild);
    }
  } catch (e) {
    debugPrint('❌ خطأ أثناء تحديث بيانات الطفل: $e');
    rethrow;
  }
}



Future<Child?> getChildInfo(String parentId, String childId) async {
  try {
    DocumentSnapshot childDoc = await _firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .get();

    if (childDoc.exists) {
      return Child.fromMap(childDoc.id, childDoc.data() as Map<String, dynamic>);
    }
  } catch (e) {
    debugPrint('Error fetching child info: $e');
  }
  return null;
}

  Future<void> deleteChild(String parentId, String childId) async {
    await _firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .delete();
  }

Future<void> deleteChildAndNavigate(BuildContext context, String parentId, String childId) async {
  await deleteChild(parentId, childId);
  Navigator.pushReplacementNamed(context, '/childListView');
}

  Future<void> addChildToParent(BuildContext context, String parentId, Child child) async {
    try {
      // الوصول إلى مجموعة الوالد ثم إضافة الطفل في مجموعة فرعية
      await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
           .add({
            ...child.toMap(), // ✅ إضافة بيانات الطفل
            'level': 1, // ✅ تحديد المستوى الافتراضي للطفل الجديد
            'stickers': [],
            'lockedContent': { 
            'letters': <String>[],
            'numbers': <String>[],
            'words': <String>[],
          },
          'progress':{
        'letters':<String>[],
        'numbers':<String>[],
        'words':<String>[],
        'EthicalValue':<String>[],
      }
          });


      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تمت إضافة الطفل بنجاح'),
              backgroundColor: Colors.green[300],
              duration: const Duration(seconds: 2),
            ),
      );

      // الرجوع بعد الإضافة الناجحة
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إضافة الطفل: $e')),
      );
    }
  }
}
