import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/EthicalValueModel.dart';

class EthicalValueController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // fetch all ethical values for the child along with the locked ones from parent
  Stream<List<EthicalValueModel>> fetchAllEthicalValues(
      String parentId, String childId) {
    return _firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .snapshots()
        .asyncMap((childSnapshot) async {

      // get locked ethical values from parent
      List<String> lockedItems = List<String>.from(
          childSnapshot.data()?['lockedContent']?['ethicalValues'] ?? []);

      QuerySnapshot ethicalSnapshot =
          await _firestore.collection('EthicalValue').get();

      return ethicalSnapshot.docs.map((doc) {
        return EthicalValueModel.fromFirestore(
            doc, lockedItems); // pass locked values to model
      }).toList();
    });
  }

  // get child's level from Firestore
  Stream<int?> fetchChildLevel(String parentId, String childId) {
    return _firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['level']);
  }

  // update child's level after completing a video
  Future<void> updateChildLevel(
      String parentId, String childId, int newLevel, String name) async {
    try {
      await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .doc(childId)
          .update({
            'level': newLevel,
            'progress.EthicalValue': FieldValue.arrayUnion([name]), // add value name to progress
          });

      print(" Child level updated to $newLevel");
    } catch (e) {
      print(" Error updating child level: $e");
    }
  }
}
