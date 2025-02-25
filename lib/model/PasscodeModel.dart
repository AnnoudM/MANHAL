import 'package:cloud_firestore/cloud_firestore.dart';

class PasscodeModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getStoredPasscode(String parentId) async {
    DocumentSnapshot doc = await _firestore.collection('Parent').doc(parentId).get();
    return doc.exists ? doc['Passcode'] as String? : null;
  }

  Future<void> savePasscode(String parentId, String passcode) async {
    await _firestore.collection('Parent').doc(parentId).set({'Passcode': passcode}, SetOptions(merge: true));
  }
}
