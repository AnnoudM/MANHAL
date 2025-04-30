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
    );
    _controller!.initializeVideo(() => setState(() {}), context);
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
                    await _controller?.saveLastPosition();
                    _controller?.videoController?.pause();
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Text(
                    widget.ethicalValue.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BLabeloo',
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Center(
            child: _controller != null &&
                    _controller!.videoController != null &&
                    _controller!.videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.videoController!.value.aspectRatio,
                    child: Chewie(controller: _controller!.chewieController!),
                  )
                : const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() async {
    await _controller?.saveLastPosition();
    _controller?.dispose();
    super.dispose();
  }
}
