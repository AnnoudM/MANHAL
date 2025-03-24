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

    // Fetch the sub-collection ("content" or "NumberContent")
    QuerySnapshot contentSnapshot;
    if (categoryName == 'numbers') {
      // Handle special case for "numbers"
      contentSnapshot = await FirebaseFirestore.instance
          .collection('Category')
          .doc(doc.id)
          .collection('NumberContent') // fetch "NumberContent" for numbers
          .get();
    } else {
      // Default case for other categories
      contentSnapshot = await FirebaseFirestore.instance
          .collection('Category')
          .doc(doc.id)
          .collection('content') // fetch "content" for letters, words
          .get();
    }

    int totalCount = contentSnapshot.size; // Count the number of documents

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

  int ethicalTotalCount = ethicalSnapshot.docs.length; // Count documents in EthicalValue
  int ethicalProgressCount = progressMap['EthicalValue'] ?? 0;

  progressList.add(ProgressModel(
    categoryName: "Ethical Values",
    progressCount: ethicalProgressCount,
    totalCount: ethicalTotalCount,
  ));

  return progressList;
}
}