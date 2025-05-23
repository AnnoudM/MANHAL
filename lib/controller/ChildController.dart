import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/child_model.dart';

class ChildController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update child info in Firestore
  Future<void> updateChildInfo(Child child, Function(Child) onUpdate) async {
    try {
      Map<String, dynamic> updateData = {
        'name': child.name,
        'age': child.age,
        'photoUrl': child.photoUrl,
        'gender': child.gender,
        'parentId': child.parentId,
      };

      await _firestore
          .collection('Parent')
          .doc(child.parentId)
          .collection('Children')
          .doc(child.id)
          .set(updateData, SetOptions(merge: true));

      debugPrint("✅ Updated child in Firebase: ${child.name}, ${child.age}");

      // Fetch updated child document
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
      debugPrint('❌ Error updating child: $e');
      rethrow;
    }
  }

  // Get specific child info by ID
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

  // Delete child from Firestore
  Future<void> deleteChild(String parentId, String childId) async {
    await _firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .delete();
  }

  // Delete and navigate back to child list
  Future<void> deleteChildAndNavigate(BuildContext context, String parentId, String childId) async {
    await deleteChild(parentId, childId);
    Navigator.pushReplacementNamed(context, '/childListView');
  }

  // Add new child under parent document
  Future<void> addChildToParent(BuildContext context, String parentId, Child child) async {
    try {
      await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .add({
            ...child.toMap(),
            'level': 1, // default level
            'stickers': [],
            'lockedContent': {
              'letters': <String>[],
              'numbers': <String>[],
              'words': <String>[],
            },
            'progress': {
              'letters': <String>[],
              'numbers': <String>[],
              'words': <String>[],
              'EthicalValue': <String>[],
            },
            'stickersProgress': {
              'numbers': 0,
              'letters': 0,
              'videos': 0,
            },
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تمت اضافة الطفل بنجاح!'),
          backgroundColor: Colors.green[300],
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ اثناء اضافة الطفل، حاول مرة أخرى')),
      );
    }
  }
}
