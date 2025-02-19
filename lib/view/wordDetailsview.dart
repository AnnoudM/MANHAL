import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WordDetailsPage extends StatefulWidget {
  final String word;
  final String category;

  const WordDetailsPage({
    super.key,
    required this.word,
    required this.category,
  });

  @override
  _WordDetailsPageState createState() => _WordDetailsPageState();
}

class _WordDetailsPageState extends State<WordDetailsPage> {
  final FlutterTts flutterTts = FlutterTts();
  String? imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWordData();
  }

  Future<void> fetchWordData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Category")
          .doc("words")
          .collection("content")
          .doc(widget.category) //
          .get();

      var data = doc.data() as Map<String, dynamic>?;

      if (data != null && data["examples"] != null && data["images"] != null) {
        int index = (data["examples"] as List).indexOf(widget.word);
        if (index != -1) {
          setState(() {
            imageUrl = (data["images"] as List)[index];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("❌ Error loading data: $e");
      setState(() => isLoading = false);
    }
  }

  void _speakWord() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.speak(widget.word);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3C7),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.all(16),
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
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      Text(
                        widget.word,
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F414E),
                          fontFamily: 'Blabeloo',
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _speakWord,
                        child: Image.asset(
                          'assets/images/high-volume.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 30),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : imageUrl != null
                              ? Image.network(
                                  imageUrl!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                )
                              : const Icon(Icons.image_not_supported,
                                  size: 100),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 289,
                height: 55,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF3C7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.arrow_back,
                        size: 34,
                        color: Color(0xFF3F414E),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "التالي",
                            style: TextStyle(
                                fontSize: 40,
                                color: Color(0xFF3F414E),
                                fontFamily: "Blabeloo"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
