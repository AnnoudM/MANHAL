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
          _updateChildLevelIfNeeded(updateUI);
        }
      });

    chewieController = ChewieController(
      videoPlayerController: videoController!,
      autoPlay: true,
      looping: false,
    );

    _fetchChildLevel(updateUI);
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
}