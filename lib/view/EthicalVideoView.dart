import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  late YoutubePlayerController _controller;
  final EthicalValueController _ethicalController = EthicalValueController();
  bool videoCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.ethicalValue.videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    )..addListener(() {
        if (_controller.value.position >= _controller.metadata.duration - const Duration(seconds: 2)) {
          setState(() {
            videoCompleted = true;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ethicalValue.name)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          YoutubePlayer(controller: _controller),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: videoCompleted
                ? () {
                    int newLevel = widget.ethicalValue.level + 1;
                    _ethicalController.updateChildLevel(widget.parentId, widget.childId, newLevel);
                    Navigator.pop(context);
                  }
                : null, // الزر يظل معطلاً حتى ينتهي الفيديو
            child: const Text("انتهيت 🎉"),
          ),
        ],
      ),
    );
  }
}