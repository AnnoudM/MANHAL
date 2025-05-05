import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../model/EthicalValueModel.dart';
import 'EthicalValueController.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Controller for managing ethical educational videos and related actions.
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

  /// Initializes the video player and listens for video completion.
  void initializeVideo(VoidCallback updateUI, BuildContext context) async {
    videoController = VideoPlayerController.network(ethicalValue.videoUrl)
      ..initialize().then((_) async {
        int? lastPosition = await loadLastPosition(); // get last saved position
        if (lastPosition != null) {
          final videoDuration = videoController!.value.duration.inMilliseconds;
          if (lastPosition < videoDuration - 1000) {
            videoController!.seekTo(Duration(milliseconds: lastPosition));
          } else {
            videoController!.seekTo(Duration.zero); // restart from beginning
          }
        }

        updateUI();
        videoController!.play();
      })
      ..addListener(() {
        if (videoController!.value.position >= videoController!.value.duration) {
          if (!videoCompleted) {
            videoCompleted = true;
            print("🎥 Video completed, updating child level...");
            _updateChildLevelIfNeeded(updateUI);
            awardEthicalStickerOnceWithDialog(context);
          }
        }
      });

    chewieController = ChewieController(
      videoPlayerController: videoController!,
      autoPlay: true,
      looping: false,
    );

    _fetchChildLevel(updateUI);
    fetchChildStickers(updateUI);
  }

  /// Saves the last playback position for the child and specific video.
  Future<void> saveLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    if (videoController != null) {
      await prefs.setInt(
        'lastPosition_${childId}_${ethicalValue.videoUrl}', // unique key per child/video
        videoController!.value.position.inMilliseconds,
      );
    }
  }

  /// Loads the last saved playback position for the child and video.
  Future<int?> loadLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastPosition_${childId}_${ethicalValue.videoUrl}');
  }

  /// Fetches the child's current ethical learning level from Firestore.
  void _fetchChildLevel(VoidCallback updateUI) async {
    _ethicalController.fetchChildLevel(parentId, childId).listen((level) {
      childCurrentLevel = level ?? 1;
      updateUI();
    });
  }

  /// Updates the child's learning level if necessary after completing the video.
  void _updateChildLevelIfNeeded(VoidCallback updateUI) {
    int nextLevel = ethicalValue.level + 1;
    if (childCurrentLevel != null && nextLevel > childCurrentLevel!) {
      _ethicalController.updateChildLevel(parentId, childId, nextLevel, ethicalValue.name);
      updateUI();

      if (onLevelComplete != null) {
        onLevelComplete!();
      }
    }
  }

  /// Returns the color of the "Done" button based on video completion.
  Color getDoneButtonColor() {
    return (videoCompleted || (childCurrentLevel != null && childCurrentLevel! > ethicalValue.level))
        ? Colors.green.shade400
        : Colors.grey.shade400;
  }

  /// Disposes video controllers and saves the last playback position.
  void dispose() {
    saveLastPosition(); // Save the last position when closing
    videoController?.dispose();
    chewieController?.dispose();
  }

  /// Awards the child a sticker for completing the video, only once.
  Future<void> awardEthicalStickerOnceWithDialog(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final stickerId = ethicalValue.level.toString(); //Each video has a sticker corresponding to its level
    final childRef = firestore.collection("Parent").doc(parentId).collection("Children").doc(childId);
    final childDoc = await childRef.get();

    if (!childDoc.exists) return;

    final data = childDoc.data() as Map<String, dynamic>;
    List<dynamic> stickers = data['stickers'] ?? [];
    List<String> stickerIds = stickers.map((s) => s['id'].toString()).toList();

    final stickerDoc = await firestore.collection("stickersVideos").doc(stickerId).get();
    if (stickerIds.contains(stickerId)) {
      await _showStickerDialog(context, stickerDoc['link']);
      return;
    }

    if (!stickerDoc.exists) {
      print(" No sticker found for level $stickerId");
      return;
    }

    final stickerLink = stickerDoc['link'];
    final newSticker = {"id": stickerId, "link": stickerLink};

    await childRef.update({
      "stickers": FieldValue.arrayUnion([newSticker]),
    });
 //After saving, display the awarded sticker in the dialog
    await _showStickerDialog(context, stickerLink);
     // Then update the child's level
    _updateChildLevelIfNeeded(() {});
  }

  /// Shows a dialog displaying the awarded sticker.
  Future<void> _showStickerDialog(BuildContext context, String link) async {
    Future.delayed(Duration(milliseconds: 200), () {
      flutterTts.speak("أَحْسَنْتَ! لَقَدْ شَاهَدْتَ الفِيدْيُو التَّعْلِيمِيَّ ");
    });

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
            const Text("لقد شاهدت الفيديو التعليمي.", textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await flutterTts.stop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
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

  /// Listens to real-time updates of the child's stickers and refreshes the UI.
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
          print("🎉 Child stickers updated: $stickersList");
          updateUI();
        }
      }
    });
  }
}
