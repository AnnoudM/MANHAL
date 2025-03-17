import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../model/EthicalValueModel.dart';
import 'EthicalValueController.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EthicalVideoController {
  final String parentId;
  final String childId;
  final EthicalValueModel ethicalValue;
  final EthicalValueController _ethicalController = EthicalValueController();

  VideoPlayerController? videoController;
  ChewieController? chewieController;
  bool videoCompleted = false;
  int? childCurrentLevel;
  VoidCallback? onLevelComplete;

  EthicalVideoController({
    required this.parentId,
    required this.childId,
    required this.ethicalValue,
    this.onLevelComplete,
  });

  /// ✅ تحميل الفيديو والتحكم به
  void initializeVideo(VoidCallback updateUI) async {
    videoController = VideoPlayerController.network(ethicalValue.videoUrl)
      ..initialize().then((_) async {
        int? lastPosition = await loadLastPosition(); // ⬅️ استرجاع الموضع الخاص بكل طفل
        if (lastPosition != null) {
          videoController!.seekTo(Duration(milliseconds: lastPosition)); // ⬅️ استئناف الفيديو
        }
        updateUI();
        videoController!.play();
      })
      ..addListener(() {
        if (videoController!.value.position >= videoController!.value.duration) {
          videoCompleted = true;
          print("🎥 الفيديو انتهى، يتم تحديث مستوى الطفل وإضافة الملصقات...");
          _updateChildLevelIfNeeded(updateUI);
          _awardStickersToChild();
        }
      });

    chewieController = ChewieController(
      videoPlayerController: videoController!,
      autoPlay: true,
      looping: false,
    );

    _fetchChildLevel(updateUI);
     fetchChildStickers(updateUI); // ✅ متابعة الملصقات الخاصة بالطفل
  }

  /// ✅ حفظ آخر موضع توقف عند الخروج لكل طفل بشكل منفصل
  Future<void> saveLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    if (videoController != null) {
      await prefs.setInt(
        'lastPosition_${childId}_${ethicalValue.videoUrl}', // ⬅️ مفتاح فريد لكل طفل وفيديو
        videoController!.value.position.inMilliseconds,
      );
    }
  }

  /// ✅ تحميل آخر موضع تم التوقف عنده لكل طفل بشكل منفصل
  Future<int?> loadLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastPosition_${childId}_${ethicalValue.videoUrl}');
  }

  /// ✅ جلب مستوى الطفل الحالي
  void _fetchChildLevel(VoidCallback updateUI) async {
    _ethicalController.fetchChildLevel(parentId, childId).listen((level) {
      childCurrentLevel = level ?? 1;
      updateUI();
    });
  }

  /// ✅ تحديث مستوى الطفل إذا لزم الأمر
  void _updateChildLevelIfNeeded(VoidCallback updateUI) {
    int nextLevel = ethicalValue.level + 1;
    if (childCurrentLevel != null && nextLevel > childCurrentLevel!) {
      _ethicalController.updateChildLevel(parentId, childId, nextLevel);
      updateUI();

      // ✅ استدعاء onLevelComplete عند انتهاء المستوى
      if (onLevelComplete != null) {
        onLevelComplete!();
      }
    }
  }

  /// ✅ لون زر "انتهى"
  Color getDoneButtonColor() {
    return (videoCompleted || (childCurrentLevel != null && childCurrentLevel! > ethicalValue.level))
        ? Colors.green.shade400
        : Colors.grey.shade400;
  }

  /// ✅ تنظيف الكائنات عند الانتهاء
  void dispose() {
    saveLastPosition(); // ⬅️ حفظ الموضع عند الإغلاق
    videoController?.dispose();
    chewieController?.dispose();
  }

void _awardStickersToChild() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  print("🚀 دخلنا دالة _awardStickersToChild للطفل $childId");

  // جلب بيانات الطفل
  DocumentSnapshot childSnapshot = await firestore
      .collection('Parent')
      .doc(parentId)
      .collection('Children')
      .doc(childId)
      .get();

  if (!childSnapshot.exists) {
    print("❌ لا يوجد بيانات لهذا الطفل $childId");
    return;
  }

  // جلب الملصقات الحالية
  List<dynamic> currentStickers = List.from(childSnapshot['stickers'] ?? []);
  List<String> currentStickerIds = currentStickers.map((sticker) => sticker['id'].toString()).toList();
  print("📦 الملصقات الحالية: $currentStickerIds");

  // جلب جميع الملصقات
  QuerySnapshot snapshot = await firestore.collection('stickers').get();
  List<DocumentSnapshot> allStickers = snapshot.docs;

  // تصفية الملصقات الجديدة
  List<DocumentSnapshot> newStickers = allStickers.where((doc) => !currentStickerIds.contains(doc.id)).toList();
  print("🆕 الملصقات الجديدة المحتملة: ${newStickers.map((e) => e.id).toList()}");

  if (newStickers.isEmpty) {
    print("⚠️ لا يوجد ملصقات جديدة لإضافتها!");
    return;
  }

  // اختيار 3 ملصقات أو أقل
  newStickers.shuffle();
  List<Map<String, dynamic>> selectedStickers = newStickers.take(3).map((doc) {
    return {'id': doc.id, 'link': doc['link']};
  }).toList();
  print("✅ الملصقات التي ستتم إضافتها: $selectedStickers");

  // دمج الملصقات
  List<Map<String, dynamic>> updatedStickers = [
    ...currentStickers.cast<Map<String, dynamic>>(),
    ...selectedStickers
  ];

  // التحديث
  await firestore
      .collection('Parent')
      .doc(parentId)
      .collection('Children')
      .doc(childId)
      .update({'stickers': updatedStickers});

  print("🔥 تم التحديث النهائي للملصقات للطفل $childId ✅ المجموع الجديد: ${updatedStickers.length}");
}


/// ✅ متابعة الملصقات الخاصة بالطفل وتحديثها في الوقت الفعلي
void fetchChildStickers(VoidCallback updateUI) {
  FirebaseFirestore.instance
      .collection('Parent')
      .doc(parentId)
      .collection('Children')
      .doc(childId)
      .snapshots()
      .listen((snapshot) {
    if (snapshot.exists) {
      var data = snapshot.data();
      if (data != null && data.containsKey('stickers')) {
        List<dynamic> stickersList = data['stickers'] ?? [];
        print("🎉 تم تحديث الملصقات للطفل: $stickersList");
        updateUI(); // ✅ تحديث الواجهة تلقائيًا عند تغيير الملصقات
      }
    }
  });
}


}


