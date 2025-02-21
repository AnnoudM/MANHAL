import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
    loadActivity(); // تحميل النشاط عند فتح الصفحة
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> loadActivity() async {
    var activity = await _controller.fetchActivity(widget.letter);
    if (mounted) {
      setState(() {
        activityData = activity;
        isLoading = false;
      });
    }
  }

  Future<void> _playAudio() async {
    if (activityData?.audioUrl != null && activityData!.audioUrl.isNotEmpty) {
      await _audioPlayer.setUrl(activityData!.audioUrl);
      await _audioPlayer.play();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ لا يوجد ملف صوتي متاح')),
      );
    }
  }

  void _checkAnswer(String selectedAnswer) {
    if (selectedAnswer == activityData?.correctAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ إجابة صحيحة!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ إجابة خاطئة، حاول مرة أخرى!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD1E3F1), // لون الخلفية الأزرق الفاتح
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : activityData == null
              ? const Center(child: Text("❌ لا يوجد نشاط متاح لهذا الحرف"))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _buildProgressBar(),
                    const SizedBox(height: 20),
                    _buildQuestion(),
                    const SizedBox(height: 10),
                    _buildAudioButton(),
                    const SizedBox(height: 20),
                    _buildOptions(),
                  ],
                ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: 0.7, // نسبة التقدم (تغييرها بناءً على التقدم الحقيقي)
          backgroundColor: Colors.white,
          color: Colors.green,
          minHeight: 10,
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        activityData?.question ?? "❌ لا يوجد سؤال متاح",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3F414E),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAudioButton() {
    return IconButton(
      icon: Image.asset(
        "assets/images/high-volume.png", // استبدالها بأيقونة الصوت
        width: 50,
        height: 50,
      ),
      onPressed: _playAudio,
    );
  }

  Widget _buildOptions() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 خيارات في كل صف
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 2.5, // التحكم في ارتفاع الأزرار
        ),
        itemCount: activityData?.options.length ?? 0,
        itemBuilder: (context, index) {
          return ElevatedButton(
            onPressed: () => _checkAnswer(activityData!.options[index]),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // لون الأزرار أبيض
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
            ),
            child: Text(
              activityData!.options[index],
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F414E),
              ),
            ),
          );
        },
      ),
    );
  }
}