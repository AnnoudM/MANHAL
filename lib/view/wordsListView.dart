import 'package:flutter/material.dart';
import '../controller/wordDetailsController.dart';
import '../model/wordDetailsModel.dart';
import '../view/wordDetailsview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WordsListPage extends StatefulWidget {
  final String parentId;
  final String childId;
  final String category;

  const WordsListPage({
    super.key,
    required this.parentId,
    required this.childId,
    required this.category,
  });

  @override
  _WordsListPageState createState() => _WordsListPageState();
}

class _WordsListPageState extends State<WordsListPage> {
  final WordController _controller = WordController();
  bool isLoading = true;
  List<WordModel> words = [];
  List<String> lockedWords = [];
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _fetchLockedWords() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Parent")
          .doc(widget.parentId)
          .collection("Children")
          .doc(widget.childId)
          .get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        lockedWords = List<String>.from(data?["lockedContent"]?["words"] ?? []);
      }
    } catch (e) {
      print("❌ Error fetching locked words: $e");
    }
  }

  Future<void> _loadWords() async {
    await _fetchLockedWords();
    List<WordModel> fetchedWords =
        await _controller.fetchWords(widget.category);
    setState(() {
      words = fetchedWords;
      isLoading = false;
    });
  }

  Future<void> _showLockedPopup(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            "الكلمة مقفلة",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "لا يمكنك الدخول إليها الآن",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        );
      },
    );

    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setVoice(
        {"name": "Microsoft Naayf - Arabic (Saudi)", "locale": "ar-SA"});
    await flutterTts.setPitch(0.6);
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(
        "هٰذِهِ الكَلِمَةُ مُقْفَلَة، لَا يُمْكِنُكَ الدُّخُولُ إِلَيْهَا الآنَ.");

    await Future.delayed(const Duration(milliseconds: 500));
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "لنتعلم بعض  ${widget.category} !",
          style: const TextStyle(
              fontSize: 24, fontFamily: 'Blabeloo', color: Color(0xFF3F414E)),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF3F414E)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : words.isEmpty
              ? const Center(child: Text("❌ لا توجد بيانات متاحة"))
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final word = words[index];
                    final isLocked = lockedWords.contains(word.word);

                    return GestureDetector(
                      onTap: () {
                        if (!isLocked) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordDetailsPage(
                                word: word.word,
                                category: widget.category,
                                parentId: widget.parentId,
                                childId: widget.childId,
                              ),
                            ),
                          );
                        } else {
                          _showLockedPopup(context);
                        }
                      },
                      child: Container(
                        width: 280,
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3C7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                word.word,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontFamily: 'Blabeloo',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3F414E),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            if (isLocked)
                              Image.asset(
                                "assets/images/Lock.png",
                                width: 30,
                                height: 30,
                              ),
                            if (!isLocked && word.imageUrl.isNotEmpty)
                              Image.network(
                                word.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
