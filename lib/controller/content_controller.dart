import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/content_model.dart';

class ContentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<ContentModel>> getContent(
      String parentId, String childId, String category) async {
    try {
      print("Fetching child document for: Parent/$parentId/Children/$childId");

      DocumentSnapshot doc = await _firestore
          .collection("Parent")
          .doc(parentId)
          .collection("Children")
          .doc(childId)
          .get();
      if (!doc.exists || doc.data() == null) {
        print(
            "No document found or data is null for: Parent/$parentId/Children/$childId");
        return [];
      }

      print(
          "Checking document: ${doc.exists ? doc.data() : "Document not found"}");

      Map<String, dynamic> data =
          (doc.data() ?? {}) as Map<String, dynamic>? ?? {};
      List<String> lockedItems = List<String>.from(data["lockedContent"]
                  ?[category]
              ?.map((num) => _convertToArabicNumbers(num)) ??
          []);

      List<ContentModel> contentList = [];

      if (category == "words") {
        QuerySnapshot subCategoriesQuery = await _firestore
            .collection("Category")
            .doc(category)
            .collection("content")
            .get();

        for (var subCategoryDoc in subCategoriesQuery.docs) {
          String subCategoryName = subCategoryDoc.id;
          bool isSubCategoryLocked = lockedItems.contains(subCategoryName);

          contentList.add(ContentModel(
            id: subCategoryName,
            name: subCategoryName,
            isLocked: isSubCategoryLocked,
            examples: [],
          ));
        }
      } else if (category == "numbers") {
        QuerySnapshot query = await _firestore
            .collection("Category")
            .doc(category)
            .collection("NumberContent")
            .get();

        for (var doc in query.docs) {
          Map<String, dynamic> numData =
              doc.data() as Map<String, dynamic>? ?? {};

          String arabicNumber = _convertToArabicNumbers(doc.id);
          contentList.add(ContentModel.fromMap(numData, arabicNumber)
              .copyWith(isLocked: lockedItems.contains(doc.id)));
        }
      } else if (category == "letters") {
        QuerySnapshot query = await _firestore
            .collection("Category")
            .doc(category)
            .collection("content")
            .get();

        for (var doc in query.docs) {
          Map<String, dynamic> letterData =
              doc.data() as Map<String, dynamic>? ?? {};
          contentList.add(ContentModel.fromMap(letterData, doc.id)
              .copyWith(isLocked: lockedItems.contains(doc.id)));
        }
      } else if (category == "ethicalValues") {
        QuerySnapshot query = await _firestore.collection("EthicalValue").get();

        for (var doc in query.docs) {
          Map<String, dynamic> ethicalData =
              doc.data() as Map<String, dynamic>? ?? {};
          String ethicalId = doc.id; // 🔥 الرقم كما هو بالإنجليزية
          String ethicalIdInArabic =
              _convertToArabicNumbers(ethicalId); // ✅ تحويله إلى العربية
          String ethicalName = ethicalData["name"] ?? "غير معروف";

          // ✅ طباعة القيم للتحقق
          print("🛠️ lockedItems from Firestore: $lockedItems");
          print(
              "🛠️ Current ethicalId (English): $ethicalId | Arabic: $ethicalIdInArabic");

          // ✅ المقارنة باستخدام الرقم العربي
          bool isLocked = lockedItems.contains(ethicalIdInArabic);

          print(
              "🔍 Checking Ethical Value: ID $ethicalId | Arabic ID: $ethicalIdInArabic | Name: $ethicalName | Locked: $isLocked");

          contentList.add(ContentModel(
            id: ethicalId,
            name: ethicalName,
            isLocked: isLocked,
          ));
        }
      }

      print("✅ Successfully fetched ${contentList.length} items.");
      return contentList;
    } catch (e) {
      print("❌ Critical Error fetching content: $e");
      return [];
    }
  }

  Future<List<ContentModel>> getWordExamples(
      String parentId, String childId, String subCategory) async {
    try {
      print("📥 Fetching words for sub-category: $subCategory");

      DocumentSnapshot? doc;
      try {
        doc = await _firestore
            .collection("Parent")
            .doc(parentId)
            .collection("Children")
            .doc(childId)
            .get();
      } catch (e) {
        print("❌ Error fetching child document: $e");
        return [];
      }

      if (doc == null || !doc.exists) {
        print("❌ Parent document not found!");
        return [];
      }

      Map<String, dynamic> parentData =
          doc.data() as Map<String, dynamic>? ?? {};
      List<String> lockedItems =
          List<String>.from(parentData["lockedContent"]?["words"] ?? []);

      DocumentSnapshot? subCategoryDoc;
      try {
        subCategoryDoc = await _firestore
            .collection("Category")
            .doc("words")
            .collection("content")
            .doc(subCategory)
            .get();
      } catch (e) {
        print("❌ Error fetching sub-category document: $e");
        return [];
      }

      if (subCategoryDoc == null || !subCategoryDoc.exists) {
        print("❌ Sub-category document not found!");
        return [];
      }
      print(
          "📥 Checking document: ${doc.exists ? doc.data() : "Document not found"}");

      Map<String, dynamic> data =
          (subCategoryDoc.data() ?? {}) as Map<String, dynamic>? ?? {};
      if (data == null || !data.containsKey("examples")) {
        print("❌ No examples found for sub-category: $subCategory");
        return [];
      }
      if (!data.containsKey("examples")) {
        print("❌ No examples found in sub-category!");
        return [];
      }

      List<ContentModel> words = (data["examples"] as List<dynamic>)
          .map((example) => ContentModel(
                id: example,
                name: example,
                isLocked: lockedItems.contains(example),
              ))
          .toList();

      print("✅ Successfully fetched ${words.length} words.");
      return words;
    } catch (e) {
      print("❌ Error fetching words: $e");
      return [];
    }
  }

  Future<void> toggleContentLock(
    String parentId,
    String childId,
    String category,
    String itemId,
    bool isLocked,
  ) async {
    try {
      DocumentReference docRef = _firestore
          .collection("Parent")
          .doc(parentId)
          .collection("Children")
          .doc(childId);

      DocumentSnapshot doc = await docRef.get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> lockedList =
            List<String>.from(data["lockedContent"][category] ?? []);

        String itemToSave =
            category == "numbers" ? _convertToEnglishNumbers(itemId) : itemId;

        if (isLocked) {
          if (!lockedList.contains(itemToSave)) lockedList.add(itemToSave);
        } else {
          lockedList.remove(itemToSave);
        }

        await docRef.update({"lockedContent.$category": lockedList});
      }
    } catch (e) {
      print("❌ Error updating content: $e");
    }
  }

  String _convertToArabicNumbers(String englishNumber) {
    const englishToArabic = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    return englishNumber
        .split('')
        .map((char) => englishToArabic[char] ?? char)
        .join();
  }

  String _convertToEnglishNumbers(String arabicNumber) {
    const arabicToEnglish = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    return arabicNumber
        .split('')
        .map((char) => arabicToEnglish[char] ?? char)
        .join();
  }
}
