import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart'; // ✅ استيراد FlutterTts
import '../controller/ActivityController.dart';
import '../model/ActivityModel.dart';

class ActivityView extends StatefulWidget {
  final String value;
  final String type;

  const ActivityView({Key? key, required this.value, required this.type})
      : super(key: key);

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  final ActivityController _controller = ActivityController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts(); // ✅ إنشاء كائن TTS
  ActivityModel? activityData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadActivity();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> loadActivity() async {
    var activity = await _controller.fetchActivity(widget.value, widget.type);
    if (mounted) {
      setState(() {
        activityData = activity;
        isLoading = false;
      });
    }
  }

  Future<void> _playAudio() async {
    if (activityData?.audioUrl != null && activityData!.audioUrl!.isNotEmpty) {
      await _audioPlayer.setUrl(activityData!.audioUrl!);
      await _audioPlayer.play();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ لا يوجد ملف صوتي متاح')),
      );
    }
  }

  Future<void> _speakQuestion() async {
    if (activityData?.question != null && activityData!.question!.isNotEmpty) {
      await flutterTts.setLanguage("ar-SA"); // ✅ تعيين اللغة للعربية
      await flutterTts.speak(activityData!.question!); // ✅ نطق السؤال
    }
  }

  @override
  Widget build(BuildContext context) {
    int repeatCount = int.tryParse(widget.value) ?? 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ الجزء العلوي مع السؤال وزر الصوت والصور
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  size: 25, color: Color(0xFF3F414E)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),

                        // ✅ تقريب السؤال من زر الصوت
                        Text(
                          activityData?.question ?? "❌ لا يوجد سؤال",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F414E),
                            fontFamily: 'Blabeloo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5), // 📌 تقليل المسافة بين السؤال وزر الصوت
                        GestureDetector(
                          onTap: _speakQuestion, // ✅ تشغيل قراءة السؤال عند الضغط
                          child: Image.asset(
                            'assets/images/high-volume.png',
                            width: 70,
                            height: 70,
                          ),
                        ),

                        // ✅ تكرار الصورة بناءً على الرقم
                        if (activityData?.imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(
                                repeatCount,
                                (index) => Image.network(
                                  activityData!.imageUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ✅ الأزرار تظهر بالكامل دون تمرير
                Expanded(
                  flex: 2,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: activityData?.options.length ?? 0,
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        onPressed: () => _checkAnswer(activityData!.options[index]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: Text(
                          activityData!.options[index],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F414E),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 5),
              ],
            ),
    );
  }

  /// ✅ **الحصول على لون الخلفية حسب نوع النشاط**
  Color _getBackgroundColor() {
    switch (widget.type) {
      case "letter":
        return const Color(0xffD1E3F1);
      case "number":
        return const Color(0xFFF9EAFB);
      case "word":
        return const Color(0xFFFFF3C7);
      default:
        return const Color(0xffD1E3F1);
    }
  }

  /// ✅ **التحقق من الإجابة**
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
}