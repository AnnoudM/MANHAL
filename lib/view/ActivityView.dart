import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../controller/ActivityController.dart';
import '../model/ActivityModel.dart';
import 'ArabicLettersView.dart';
import 'ArabicNumberView.dart';
import 'ArabicWordsView.dart';
import '../constants/word_categories.dart';

/// Converts an English category key into its Arabic equivalent for display.
String categoryNameToArabic(String key) {
  switch (key) {
    case 'shapes':
      return 'الأشكال';
    case 'colors':
      return 'الألوان';
    case 'animals':
      return 'الحيوانات';
    case 'food':
      return 'الطعام';
    default:
      return 'الكلمات';
  }
}

class ActivityView extends StatefulWidget {
  final String parentId;
  final String childId;
  final String value;
  final String type;

  const ActivityView({
    Key? key,
    required this.parentId,
    required this.childId,
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
  /// Disposes audio resources when the activity view is closed.
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
/// Loads the activity data from Firestore based on the provided value and type.
  Future<void> loadActivity() async {
    var activity = await _controller.fetchActivity(widget.value, widget.type);
    if (mounted) {
      setState(() {
        activityData = activity;
        isLoading = false;
      });
    }
  }

/// Uses text-to-speech (TTS) to speak a provided Arabic message.
  Future<void> _speakMessage(String message) async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.speak(message);
  }

/// Displays a dialog showing whether the answer was correct or incorrect, and navigates based on the result.
void _showAnswerDialog(bool isCorrect, [String? earnedStickerUrl]) async {
  String message = isCorrect ? "إجابة صحيحة! أكمل التعلم." : "إجابة خاطئة! حاول مرة أخرى.";
  Color textColor = isCorrect ? Colors.green : Colors.red;
  String buttonText = "حسنًا";

  Widget nextPage;
  switch (widget.type) {
    case "letter":
      nextPage = ArabicLettersView(parentId: widget.parentId, childId: widget.childId);
      break;
    case "number":
      nextPage = ArabicNumberView(parentId: widget.parentId, childId: widget.childId);
      break;
    case "word":
      nextPage = ArabicWordsPage(parentId: widget.parentId, childId: widget.childId);
      break;
    default:
      nextPage = ArabicLettersView(parentId: widget.parentId, childId: widget.childId);
  }

  // ✅ لا تعيد جلب الستكر، استخدم فقط earnedStickerUrl
  String stickerPath = isCorrect
      ? (earnedStickerUrl ?? 'assets/images/default_sticker.png')
      : 'assets/images/Sad.png';

  VoidCallback onPressed = isCorrect
      ? () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => nextPage),
          );
        }
      : () {
          Navigator.pop(context);
        };

  _speakMessage(message);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isCorrect ? "إجابة صحيحة!" : "إجابة خاطئة!",
          style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            stickerPath.startsWith("http")
                ? Image.network(stickerPath, width: 100, height: 100, fit: BoxFit.contain)
                : Image.asset(stickerPath, width: 100, height: 100),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: Colors.green.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(buttonText, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      );
    },
  );
}

/// Checks if the selected answer is correct, updates progress, and shows appropriate feedback.
  void _checkAnswer(String selectedAnswer) async {
    bool isCorrect = selectedAnswer == activityData?.correctAnswer;
    String? earnedStickerUrl;
    if (isCorrect) {
      bool hasAnswered = await _controller.hasAnsweredCorrectly(widget.parentId, widget.childId, widget.type, selectedAnswer);
      if (hasAnswered) {
      _showRepeatedAnswerDialog(); // ديلوق مخصص
      return;
    }
      if (!hasAnswered) {
     if (widget.type == "number") {
  final stickerUrl = await _controller.getNextNumberSticker(
    parentId: widget.parentId,
    childId: widget.childId,
    number: selectedAnswer,
  );

  if (stickerUrl != null) {
    earnedStickerUrl = stickerUrl; // ⬅️ نخزن الرابط هنا
    await _controller.addStickerToChild(
  widget.parentId,
  widget.childId,
  selectedAnswer, // بس نرسل الـ ID حق الرقم
);
  }
}
else if (widget.type == "letter") {
  final stickerUrl = await _controller.getLetterSticker(
    parentId: widget.parentId,
    childId: widget.childId,
    letter: selectedAnswer,
  );

  if (stickerUrl != null) {
    earnedStickerUrl = stickerUrl;
    await _controller.addLetterStickerToChild(
      parentId: widget.parentId,
      childId: widget.childId,
      letter: selectedAnswer,
    );
  }
}else if (widget.type == "word") {
  final stickerUrl = await _controller.updateWordProgressAndCheckSticker(
    parentId: widget.parentId,
    childId: widget.childId,
    word: selectedAnswer,
  );

  if (stickerUrl != null) {
    earnedStickerUrl = stickerUrl;
     
   await _controller.addWordCategoryStickerToChild(
    parentId: widget.parentId,
    childId: widget.childId,
    category: wordToCategory[selectedAnswer] ?? "",
    link: stickerUrl,
  );

  } else {
        // 🟢 لا يوجد ستيكر حالياً، نعرض رسالة تشجيعية
        final category = wordToCategory[selectedAnswer] ?? "الكلمات";
        _showProgressDialog(categoryNameToArabic(category));
        return;
      }
}
     //   await _controller.updateProgressWithAnswer(widget.parentId, widget.childId, widget.type, selectedAnswer);
      }
    }

    _showAnswerDialog(isCorrect,earnedStickerUrl);
  }

/// Shows a special dialog when the child has already answered this activity before.
void _showRepeatedAnswerDialog() {
  Widget nextPage;
  switch (widget.type) {
    case "letter":
      nextPage = ArabicLettersView(parentId: widget.parentId, childId: widget.childId);
      break;
    case "number":
      nextPage = ArabicNumberView(parentId: widget.parentId, childId: widget.childId);
      break;
    case "word":
      nextPage = ArabicWordsPage(parentId: widget.parentId, childId: widget.childId);
      break;
    default:
      nextPage = ArabicLettersView(parentId: widget.parentId, childId: widget.childId);
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "تمت الإجابة سابقًا",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "لقد أجبت على هذا السؤال من قبل، جرّب سؤالًا جديدًا!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => nextPage),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("حسنًا", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      );
    },
  );
}

/// Builds the UI of the activity page, displaying the question, options, and media.
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
                            Text(
                              activityData?.question ?? "❌ لا يوجد سؤال",
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F414E),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => _speakMessage(activityData?.question ?? ""),
                              child: Image.asset(
                                'assets/images/high-volume.png',
                                width: 70,
                                height: 70,
                              ),
                            ),
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
          Positioned(
            top: 40,
            right: 10,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              mini: true,
              backgroundColor: Colors.white.withOpacity(0.7),
              child: Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

/// Returns a specific background color based on the activity type (letter, number, or word).
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
 
  /// Displays a motivational dialog encouraging the child to complete a category for a sticker reward.
  void _showProgressDialog(String categoryName)async {

  await flutterTts.setLanguage("ar-SA"); // Set language to Arabic for TTS
  await flutterTts.speak("ممتاز! أكمل باقي الأسئلة لمجموعة $categoryName لتحصل على ملصق");

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "إجابة صحيحة!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              "ممتاز! أكمل باقي الأسئلة لمجموعة \"$categoryName\" لتحصل على ملصق 🎁",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
    Navigator.of(context).pop(); 
    Navigator.of(context).pop(); 
    Navigator.of(context).pop(); 
     Navigator.of(context).pop(); 
  },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("متابعة", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      );
    },
  );
}

}