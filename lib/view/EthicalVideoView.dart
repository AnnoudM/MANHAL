import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../controller/EthicalValueController.dart';
import '../model/EthicalValueModel.dart';

class EthicalVideoView extends StatefulWidget {
  final String parentId;
  final String childId;
  final EthicalValueModel ethicalValue;

  const EthicalVideoView({
    Key? key,
    required this.parentId,
    required this.childId,
    required this.ethicalValue,
  }) : super(key: key);

  @override
  _EthicalVideoViewState createState() => _EthicalVideoViewState();
}

class _EthicalVideoViewState extends State<EthicalVideoView> {
  final EthicalValueController _ethicalController = EthicalValueController();
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool videoCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  // 🔹 تحميل الفيديو من Firebase Storage
  void _loadVideo() async {
    String videoUrl = widget.ethicalValue.videoUrl;
    setState(() {
      _videoController = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        })
        ..addListener(() {
          if (_videoController!.value.position >= _videoController!.value.duration) {
            setState(() {
              videoCompleted = true;
            });

            // ✅ تحديث مستوى الطفل تلقائيًا عند انتهاء الفيديو
            int nextLevel = widget.ethicalValue.level + 1;
            _ethicalController.updateChildLevel(widget.parentId, widget.childId, nextLevel);
          }
        });

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
      );
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ethicalValue.name),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 الفيديو في منتصف الشاشة
            _videoController != null && _videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 30),

            // 🔹 زر "انتهيت ✅" باللون الأخضر الفاتح
            ElevatedButton(
              onPressed: videoCompleted
                  ? () {
                      int nextLevel = widget.ethicalValue.level + 1;
                      _ethicalController.updateChildLevel(widget.parentId, widget.childId, nextLevel);
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 171, 238, 174), // ✅ لون أخضر فاتح
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: const Text("انتهيت ✅"),
            ),
          ],
        ),
      ),
    );
  }
}