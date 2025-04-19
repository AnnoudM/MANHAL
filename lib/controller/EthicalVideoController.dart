import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../model/EthicalValueModel.dart';
import 'EthicalValueController.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';


class EthicalVideoController {
  final String parentId;
  final String childId;
  final EthicalValueModel ethicalValue;
  final EthicalValueController _ethicalController = EthicalValueController();
  final FlutterTts flutterTts = FlutterTts();


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
  void initializeVideo(VoidCallback updateUI, BuildContext context) async {
    videoController = VideoPlayerController.network(ethicalValue.videoUrl)
      ..initialize().then((_) async {
        int? lastPosition = await loadLastPosition(); // ⬅️ استرجاع الموضع الخاص بكل طفل
       if (lastPosition != null) {
  final videoDuration = videoController!.value.duration.inMilliseconds;
  if (lastPosition < videoDuration - 1000) {
    videoController!.seekTo(Duration(milliseconds: lastPosition));
  } else {
    videoController!.seekTo(Duration.zero); // يبدأ من البداية
  }
}

        updateUI();
        videoController!.play();
      })
      ..addListener(() {
        if (videoController!.value.position >= videoController!.value.duration) {
        if (!videoCompleted) {
      videoCompleted = true;
      print("🎥 الفيديو انتهى، يتم تحديث مستوى الطفل وت...");
      _updateChildLevelIfNeeded(updateUI);
      awardEthicalStickerOnceWithDialog(context); // ✅ فعّل المكافأة هنا
    }
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
      _ethicalController.updateChildLevel(parentId, childId, nextLevel, ethicalValue.name);
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

Future<void> awardEthicalStickerOnceWithDialog(BuildContext context) async {
  final firestore = FirebaseFirestore.instance;
  final stickerId = ethicalValue.level.toString(); // كل فيديو له ستكر بنفس رقم المستوى
  final childRef = firestore.collection("Parent").doc(parentId).collection("Children").doc(childId);
  final childDoc = await childRef.get();

  if (!childDoc.exists) return;

  final data = childDoc.data() as Map<String, dynamic>;
  List<dynamic> stickers = data['stickers'] ?? [];
  List<String> stickerIds = stickers.map((s) => s['id'].toString()).toList();

  if (stickerIds.contains(stickerId)) {
    _showAlreadyWatchedDialog(context); // ✅ تم مشاهدة هذا الفيديو سابقًا
    return;
  }

  final stickerDoc = await firestore.collection("stickers").doc(stickerId).get();
  if (!stickerDoc.exists) {
    print("❌ لا يوجد ستكر مرتبط بـ level $stickerId");
    return;
  }

  final stickerLink = stickerDoc['link'];
  final newSticker = {"id": stickerId, "link": stickerLink};

  await childRef.update({
    "stickers": FieldValue.arrayUnion([newSticker]),
  });

  // ✅ بعد الحفظ نعرض نفس الستكر في الديالوق
  await _showStickerDialog(context, stickerLink);

  // ✅ بعدها نحدث المستوى
  _updateChildLevelIfNeeded(() {}); // نمرر دالة فاضية لو ما تحتاج تحديث UI مباشر
}

Future<void> _showStickerDialog(BuildContext context, String link) async {

await flutterTts.speak("أحسنت! لقد شاهدت الفيديو التعليمي بالكامل.");
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text("أحسنت!", textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(link, width: 100, height: 100),
          const SizedBox(height: 10),
          const Text(" لقد شاهدت الفيديو التعليمي بالكامل، أكمل التعلم.", textAlign: TextAlign.center),
        ],
      ),
      actions: [
        Center(
           child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // يغلق الديالوق
              Navigator.of(context).pop(); // يرجع للصفحة السابقة
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "حسناً",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'BLabeloo',
  ),
),

          ),
        ),
      ],
    ),
  );
}

void _showAlreadyWatchedDialog(BuildContext context) async {

await flutterTts.speak("لقد شاهدت هذا الفيديو من قبل. جرّب فيديو آخر!"); 

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text("تمت المشاهدة سابقًا", textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
      content: const Text("لقد شاهدت هذا الفيديو من قبل. جرّب فيديو آخر!", textAlign: TextAlign.center),
      actions: [
        Center(
          child: TextButton(
            onPressed: () {
  Navigator.of(context).pop(); // يغلق الديالوق
  Navigator.of(context).pop(); // يرجع للخلف
},

            child: const Text("حسنًا", style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    ),
  );
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


