import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../controller/ActivityController.dart';
import '../model/ActivityModel.dart';

class ActivityView extends StatefulWidget {
  final String parentId; // ✅ معرف الوالد
  final String childId;  // ✅ معرف الطفل
  final String value;
  final String type;

  const ActivityView({
    Key? key,
    required this.parentId, // ✅ تمرير parentId عند استدعاء الصفحة
    required this.childId,  // ✅ تمرير childId عند استدعاء الصفحة
    required this.value,
    required this.type,
  }) : super(key: key);

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  final ActivityController _controller = ActivityController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();
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

  Future<void> _speakQuestion() async {
    if (activityData?.question != null && activityData!.question!.isNotEmpty) {
      await flutterTts.setLanguage("ar-SA");
      await flutterTts.speak(activityData!.question!);
    }
  }

  @override
  Widget build(BuildContext context) {
    int repeatCount = int.tryParse(widget.value) ?? 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // ✅ الجزء العلوي يحتوي على السؤال، زر الصوت، والصور
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
                            // ✅ عرض السؤال
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
                            const SizedBox(height: 10),

                            // ✅ زر تشغيل الصوت
                            GestureDetector(
                              onTap: _speakQuestion,
                              child: Image.asset(
                                'assets/images/high-volume.png',
                                width: 70,
                                height: 70,
                              ),
                            ),

                            // ✅ عرض الصور بناءً على القيمة
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

                    // ✅ أزرار الاختيار
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: GridView.builder(
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
                  ],
                ),

          // ✅ زر الرجوع الوحيد في أعلى الصفحة
          Positioned(
            top: 40,
            right: 10,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              mini: true,
              backgroundColor: Colors.white.withOpacity(0.7),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
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
  void _checkAnswer(String selectedAnswer) async {
  if (selectedAnswer == activityData?.correctAnswer) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ إجابة صحيحة!')),
    );
    print("🔹 استدعاء addStickerToChild بعد الإجابة الصحيحة");

    // ✅ إضافة الملصق للطفل في Firestore عند الإجابة الصحيحة
    await _controller.addStickerToChild(widget.parentId, widget.childId, "1"); // تأكد من أن stickerId صحيح

    // ✅ استدعاء دالة تحديث التقدم بعد الإجابة الصحيحة
    await _controller.updateProgress(widget.parentId, widget.childId, widget.type);  // هنا يتم تحديد نوع النشاط
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ إجابة خاطئة، حاول مرة أخرى!')),
    );
  }
}
}