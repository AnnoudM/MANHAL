import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../controller/EthicalVideoController.dart';
import '../model/EthicalValueModel.dart';

class EthicalVideoView extends StatefulWidget {
  final String parentId;
  final String childId;
  final EthicalValueModel ethicalValue;

  const EthicalVideoView({
    super.key,
    required this.parentId,
    required this.childId,
    required this.ethicalValue,
  });

  @override
  _EthicalVideoViewState createState() => _EthicalVideoViewState();
}

class _EthicalVideoViewState extends State<EthicalVideoView> {
  EthicalVideoController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = EthicalVideoController(
      parentId: widget.parentId,
      childId: widget.childId,
      ethicalValue: widget.ethicalValue,
      //onLevelComplete: _showCompletionDialog,
    );
    _controller!.initializeVideo(() => setState(() {}), context);
  }

  /// ✅ عرض رسالة نجاح عند إنهاء مرحلة والانتقال للمستوى التالي
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
                  Navigator.of(context).pop(); // يغلق الديالوق
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("حسناً",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'BLabeloo'),
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
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackGroundManhal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                  onPressed: () async {
                    await _controller?.saveLastPosition(); // ✅ حفظ الموضع عند الرجوع
                    _controller?.videoController?.pause();
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Text(
                    widget.ethicalValue.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BLabeloo',
                      color: Colors.black,
                    ),),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controller != null && _controller!.videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.videoController!.value.aspectRatio,
                        child: Chewie(controller: _controller!.chewieController!),
                      )
                    : const CircularProgressIndicator(),
                const SizedBox(height: 20),

                // ✅ زر "انتهى"
                GestureDetector(
                  onTap: () {
                    if (_controller!.videoCompleted ||
                        (_controller!.childCurrentLevel != null &&
                            _controller!.childCurrentLevel! > widget.ethicalValue.level)) {
                     _controller!.awardEthicalStickerOnceWithDialog(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("يجب إكمال المقطع التعليمي أولًا!"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _controller!.getDoneButtonColor(),
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

  @override
  void dispose() async {
    await _controller?.saveLastPosition(); // ✅ حفظ الموضع عند الإغلاق
    _controller?.dispose();
    super.dispose();
  }
}