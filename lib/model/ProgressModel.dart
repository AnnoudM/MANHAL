import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  String categoryName;
  int progressCount;
  int totalCount;

  ProgressModel({
    required this.categoryName,
    required this.progressCount,
    required this.totalCount,
  });

  static Future<List<ProgressModel>> fetchProgress(String parentId, String childId) async {
    List<ProgressModel> progressList = [];

    // get child's data
    DocumentSnapshot childDoc = await FirebaseFirestore.instance
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .get();

    // make sure "progress" exists
    Map<String, dynamic> progressMap = {};
    if (childDoc.exists && childDoc.data() != null) {
      progressMap = (childDoc.data() as Map<String, dynamic>)['progress'] ?? {};
    }

    // get all categories (letters, numbers, words)
    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance.collection('Category').get();

    for (var doc in categorySnapshot.docs) {
      String categoryName = doc.id;
      int totalCount = 0;

      if (categoryName == 'numbers') {
        // count all number items
        QuerySnapshot contentSnapshot = await FirebaseFirestore.instance
            .collection('Category')
            .doc(doc.id)
            .collection('NumberContent')
            .get();
        totalCount = contentSnapshot.size;
      } else if (categoryName == 'words') {
        // count total word examples inside subcategories
        QuerySnapshot contentSnapshot = await FirebaseFirestore.instance
            .collection('Category')
            .doc(doc.id)
            .collection('content')
            .get();

        for (var subDoc in contentSnapshot.docs) {
          Map<String, dynamic> subData = subDoc.data() as Map<String, dynamic>;
          if (subData.containsKey('examples') && subData['examples'] is List) {
            totalCount += (subData['examples'] as List).length;
          }
        }
      } else {
        // count for other categories like letters
        QuerySnapshot contentSnapshot = await FirebaseFirestore.instance
            .collection('Category')
            .doc(doc.id)
            .collection('content')
            .get();
        totalCount = contentSnapshot.size;
      }

      // extract progress count from list
      int progressCount = 0;
      if (progressMap.containsKey(categoryName)) {
        var progressData = progressMap[categoryName];
        if (progressData is List) {
          progressCount = progressData.length;
        }
      }

      progressList.add(ProgressModel(
        categoryName: categoryName,
        progressCount: progressCount,
        totalCount: totalCount,
      ));
    }

    // handle progress for Ethical Values
    QuerySnapshot ethicalSnapshot = await FirebaseFirestore.instance.collection('EthicalValue').get();
    int ethicalTotalCount = ethicalSnapshot.docs.length;
    int ethicalProgressCount = 0;

    if (progressMap.containsKey('EthicalValue')) {
      var ethicalData = progressMap['EthicalValue'];
      if (ethicalData is List) {
        ethicalProgressCount = ethicalData.length;
      }
    }

    progressList.add(ProgressModel(
      categoryName: "Ethical Values",
      progressCount: ethicalProgressCount,
      totalCount: ethicalTotalCount,
    ));

    return progressList;
  }
}
