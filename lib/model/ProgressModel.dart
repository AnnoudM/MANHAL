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

    // ✅ جلب بيانات الطفل
    DocumentSnapshot childDoc = await FirebaseFirestore.instance
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .doc(childId)
        .get();

    // ✅ التأكد من وجود progress قبل استخدامه
    Map<String, dynamic> progressMap = {};
    if (childDoc.exists && childDoc.data() != null) {
      progressMap = (childDoc.data() as Map<String, dynamic>)['progress'] ?? {};
    }

    // ✅ جلب جميع الفئات (الحروف، الأرقام، الكلمات)
    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance.collection('Category').get();

    for (var doc in categorySnapshot.docs) {
      String categoryName = doc.id;
      int totalCount = 0;

      if (categoryName == 'numbers') {
        // ✅ حساب العدد الكلي للأرقام
        QuerySnapshot contentSnapshot = await FirebaseFirestore.instance
            .collection('Category')
            .doc(doc.id)
            .collection('NumberContent')
            .get();
        totalCount = contentSnapshot.size;
      } else if (categoryName == 'words') {
        // ✅ حساب العدد الكلي للكلمات (داخل التصنيفات الفرعية)
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
        // ✅ الحساب لبقية الفئات مثل الحروف
        QuerySnapshot contentSnapshot = await FirebaseFirestore.instance
            .collection('Category')
            .doc(doc.id)
            .collection('content')
            .get();
        totalCount = contentSnapshot.size;
      }

      // ✅ استخراج التقدم بناءً على المصفوفة
      int progressCount = 0;
      if (progressMap.containsKey(categoryName)) {
        var progressData = progressMap[categoryName];
        if (progressData is List) {
          progressCount = progressData.length; // ✅ احسب عدد العناصر داخل المصفوفة
        }
      }

      progressList.add(ProgressModel(
        categoryName: categoryName,
        progressCount: progressCount,
        totalCount: totalCount,
      ));
    }

    // ✅ حساب تقدم القيم الأخلاقية (Ethical Values)
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