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

  static Future<List<ProgressModel>> fetchProgress(
      String parentId, String childId) async {
    List<ProgressModel> progressList = [];

    // Fetch child's document
    DocumentSnapshot childDoc = await FirebaseFirestore.instance
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .get();

    // Extract progress map
    Map<String, dynamic> progressMap = childDoc['progress'];

    // Fetch categories (letters, numbers, words)
    QuerySnapshot categorySnapshot =
        await FirebaseFirestore.instance.collection('Category').get();

    for (var doc in categorySnapshot.docs) {
      String categoryName = doc.id;
      int totalCount = 0;

      if (categoryName == 'numbers') {
        // Handle special case for "numbers"
        QuerySnapshot contentSnapshot = await FirebaseFirestore.instance
            .collection('Category')
            .doc(doc.id)
            .collection('NumberContent')
            .get();
        totalCount = contentSnapshot.size;
      } else if (categoryName == 'words') {
        // Handle special case for "words"
        QuerySnapshot contentSnapshot = await FirebaseFirestore.instance
            .collection('Category')
            .doc(doc.id)
            .collection('content')
            .get();

        // Loop through each subcategory (shapes, colors, animals, food)
        for (var subDoc in contentSnapshot.docs) {
          Map<String, dynamic> subData = subDoc.data() as Map<String, dynamic>;

          if (subData.containsKey('examples') && subData['examples'] is List) {
            List examples = subData['examples']; // Extract words list
            totalCount += examples.length; // Add word count
          }
        }
      } else {
        // Default case for other categories (letters, etc.)
        QuerySnapshot contentSnapshot = await FirebaseFirestore.instance
            .collection('Category')
            .doc(doc.id)
            .collection('content')
            .get();
        totalCount = contentSnapshot.size;
      }

      // Match progress for the category
      int progressCount = progressMap[categoryName] ?? 0;

      progressList.add(ProgressModel(
        categoryName: categoryName,
        progressCount: progressCount,
        totalCount: totalCount,
      ));
    }

    // Fetch Ethical Values
    QuerySnapshot ethicalSnapshot =
        await FirebaseFirestore.instance.collection('EthicalValue').get();

    int ethicalTotalCount = ethicalSnapshot.docs.length;
    int ethicalProgressCount = progressMap['EthicalValue'] ?? 0;

    progressList.add(ProgressModel(
      categoryName: "Ethical Values",
      progressCount: ethicalProgressCount,
      totalCount: ethicalTotalCount,
    ));

    return progressList;
  }
}