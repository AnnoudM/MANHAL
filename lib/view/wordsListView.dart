import 'package:flutter/material.dart';
import '../controller/wordDetailsController.dart';
import '../model/wordDetailsModel.dart';
import '../view/wordDetailsview.dart';

class WordsListPage extends StatefulWidget {
  final String category;

  const WordsListPage({super.key, required this.category});

  @override
  _WordsListPageState createState() => _WordsListPageState();
}

class _WordsListPageState extends State<WordsListPage> {
  final WordController _controller = WordController();
  bool isLoading = true;
  List<WordModel> words = [];

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  void _loadWords() async {
    List<WordModel> fetchedWords =
        await _controller.fetchWords(widget.category);
    setState(() {
      words = fetchedWords;
      isLoading = false;
    });
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
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordDetailsPage(
                              word: words[index].word,
                              category: widget.category,
                            ),
                          ),
                        );
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
                                words[index].word,
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
                            (words[index].imageUrl.isNotEmpty)
                                ? Image.network(
                                    words[index].imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image_not_supported,
                                    size: 50),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
