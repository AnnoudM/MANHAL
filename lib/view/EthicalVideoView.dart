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
  int? childCurrentLevel;

  @override
  void initState() {
    super.initState();
    _loadVideo();
    _fetchChildLevel();
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

            // ✅ تحديث مستوى الطفل فقط إذا كان المستوى الجديد أعلى
            int nextLevel = widget.ethicalValue.level + 1;
            if (childCurrentLevel != null && nextLevel > childCurrentLevel!) {
              _ethicalController.updateChildLevel(widget.parentId, widget.childId, nextLevel);

              // ✅ عرض رسالة النجاح بناءً على المستوى
              Future.delayed(const Duration(milliseconds: 500), () {
                if (nextLevel == 7) {
                  _showCompletionDialogFinal();
                } else {
                  _showCompletionDialog();
                }
              });
            }
          }
        });

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
      );
    });
  }

  // 🔹 جلب مستوى الطفل الحالي من Firestore
  void _fetchChildLevel() async {
    _ethicalController.fetchChildLevel(widget.parentId, widget.childId).listen((level) {
      if (mounted) {
        setState(() {
          childCurrentLevel = level ?? 1;
        });
      }
    });
  }

  // ✅ عرض رسالة نجاح عند إنهاء مرحلة والانتقال للمستوى التالي
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/happyChick.png", width: 100),
              const SizedBox(height: 10),
              Text(
                "🎉 أحسنت! لقد أتممت مرحلة \"${widget.ethicalValue.name}\" وانتقلت إلى المستوى التالي.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BLabeloo',
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("حسناً",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'BLabeloo'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ عرض رسالة خاصة إذا أتم الطفل جميع القيم ووصل للمستوى 7
  void _showCompletionDialogFinal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/trophy.png", width: 100),
              const SizedBox(height: 10),
              const Text(
                "🏆 مبروك! لقد أتممت جميع المراحل بنجاح!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BLabeloo',
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "رائع! 🎉",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'BLabeloo'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 🔹 الخلفية تغطي الشاشة بالكامل
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackGroundManhal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 AppBar داخل الخلفية (شفاف)
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  widget.ethicalValue.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BLabeloo',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _videoController != null && _videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: Chewie(controller: _chewieController!),
                      )
                    : const CircularProgressIndicator(),
                const SizedBox(height: 20),

                // 🔹 زر "انتهى" مع التعديلات المطلوبة
                GestureDetector(
                  onTap: () {
                    if (childCurrentLevel != null &&
                        childCurrentLevel! > widget.ethicalValue.level) {
                      Navigator.pop(context);
                    } else if (!videoCompleted) {ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("يجب إكمال المقطع التعليمي أولًا!"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 50,
                    decoration: BoxDecoration(
                      color: videoCompleted || (childCurrentLevel != null &&
                              childCurrentLevel! > widget.ethicalValue.level)
                          ? Colors.green.shade400
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "انتهى",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BLabeloo',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}