import 'package:cloud_firestore/cloud_firestore.dart';

class PasscodeModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // استرجاع رمز المرور المخزن في قاعدة البيانات
  Future<String?> getStoredPasscode(String parentId) async {
    DocumentSnapshot doc =
        await _firestore.collection('Parent').doc(parentId).get();
    return doc.exists ? doc['Passcode'] as String? : null;
  }

  // حفظ رمز المرور الجديد
  Future<void> savePasscode(String parentId, String passcode) async {
    await _firestore.collection('Parent').doc(parentId).set({'Passcode': passcode}, SetOptions(merge: true));
  }
}
