import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/ActivityController.dart';
import 'package:manhal/model/ActivityModel.dart';

class ActivityView extends StatefulWidget {
  final String letter;

  const ActivityView({Key? key, required this.letter}) : super(key: key);

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  final ActivityController _controller = ActivityController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  ActivityModel? activityData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("✅ ActivityView تم فتحه للحرف: ${widget.letter}");
    loadActivity(); // ✅ استدعاء تحميل البيانات عند فتح الصفحة
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> loadActivity() async {
    print("📡 جاري تحميل بيانات Firebase للحرف: ${widget.letter}");
    
    var activity = await _controller.fetchActivity(widget.letter);
    
    if (mounted) {
      setState(() {
        activityData = activity;
        isLoading = false;
      });
    }
    
    print("✅ تم تحميل البيانات: ${activityData?.question ?? '❌ لا يوجد بيانات'}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE5F2FF),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : activityData == null
              ? const Center(
                  child: Text(
                    "❌ لا يوجد نشاط لهذا الحرف",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                )
              : Column(
                  children: [
                    _buildQuestion(),
                    const SizedBox(height: 20),
                    _buildAudioButton(),
                    const SizedBox(height: 20),
                    _buildOptions(),
                  ],
                ),
    );
  }

  Widget _buildQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        activityData?.question ?? "❌ لا يوجد سؤال متاح",
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAudioButton() {
    return IconButton(
      icon: const Icon(Icons.volume_up, size: 40, color: Colors.deepOrange),
      onPressed: () async {
        if (activityData?.audioUrl != null && activityData!.audioUrl.isNotEmpty) {
          await _audioPlayer.setUrl(activityData!.audioUrl);
          await _audioPlayer.play();
        } else {
          print("⚠️ لا يوجد ملف صوتي متاح لهذا الحرف");
        }
      },
    );
  }

  Widget _buildOptions() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: activityData?.options.length ?? 0,
        itemBuilder: (context, index) {
          return ElevatedButton(
            onPressed: () {
              if (activityData?.options[index] == activityData?.correctAnswer) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ إجابة صحيحة!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ إجابة خاطئة، حاول مرة أخرى!')),
                );
              }
            },
            child: Text(activityData?.options[index] ?? ""),
          );
        },
      ),
    );
  }
}