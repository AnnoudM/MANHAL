import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../controller/ActivityController.dart';
import '../model/ActivityModel.dart';
import 'ArabicLettersView.dart';
import 'ArabicNumberView.dart';
import 'ArabicWordsView.dart';


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

  Future<void> _speakMessage(String message) async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.speak(message);
  }

  void _showAnswerDialog(bool isCorrect) async {
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

    String stickerPath = isCorrect
        ? await _controller.getRandomStickerFromFirestore()
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
              Image.asset(stickerPath, width: 100, height: 100),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center, // جعل الزر في المنتصف
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

  void _checkAnswer(String selectedAnswer) async {
    bool isCorrect = selectedAnswer == activityData?.correctAnswer;

    if (isCorrect) {
      bool hasAnswered = await _controller.hasAnsweredCorrectly(widget.parentId, widget.childId, widget.type, selectedAnswer);

      if (!hasAnswered) {
        await _controller.addStickerToChild(widget.parentId, widget.childId, "1");
        await _controller.updateProgressWithAnswer(widget.parentId, widget.childId, widget.type, selectedAnswer);
      }
    }

    _showAnswerDialog(isCorrect);
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
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case "letter": return const Color(0xffD1E3F1);
      case "number": return const Color(0xFFF9EAFB);
      case "word": return const Color(0xFFFFF3C7);
      default: return const Color(0xffD1E3F1);
    }
  }
}