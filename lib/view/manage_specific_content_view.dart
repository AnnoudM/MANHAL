import 'package:flutter/material.dart';
import '../controller/content_controller.dart';
import '../model/content_model.dart';

class ManageSpecificContentView extends StatefulWidget {
  final String parentId;
  final String childId;
  final String category;

  const ManageSpecificContentView({
    super.key,
    required this.parentId,
    required this.childId,
    required this.category,
  });

  @override
  _ManageSpecificContentViewState createState() =>
      _ManageSpecificContentViewState();
}

class _ManageSpecificContentViewState extends State<ManageSpecificContentView> {
  final ContentController _contentController = ContentController();
  List<ContentModel> contentList = [];
  bool isLoading = true;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    setState(() => isLoading = true);

    if (widget.category == "words" && selectedCategory != null) {
      contentList = await _contentController.getWordExamples(
        widget.parentId,
        widget.childId,
        selectedCategory!,
      );
    } else {
      contentList = await _contentController.getContent(
        widget.parentId,
        widget.childId,
        widget.category,
      );

      if (widget.category == "numbers") {
        contentList.sort((b, a) {
          int numA = _arabicToEnglishNumber(a.name);
          int numB = _arabicToEnglishNumber(b.name);
          return numB.compareTo(numA); 
        });
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  int _arabicToEnglishNumber(String arabicNumber) {
    const arabicToEnglish = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    String englishNumber = arabicNumber.split('').map((char) {
      return arabicToEnglish[char] ?? '';
    }).join();

    return int.tryParse(englishNumber) ?? 0;
  }

  Future<void> _confirmToggleLock(ContentModel item) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد العملية"),
        content: Text(
            "هل أنت متأكد أنك تريد ${item.isLocked ? "فتح" : "قفل"} ${item.name} لطفلك؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("نعم"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _contentController.toggleContentLock(
        widget.parentId,
        widget.childId,
        widget.category,
        item.id,
        !item.isLocked,
      );
      _fetchContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      backgroundColor: Colors.transparent, 
      appBar: AppBar(
        title: Text(
          selectedCategory == null
              ? _getCategoryTitle(widget.category)
              : selectedCategory!,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, 
        elevation: 0, 
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/BackGroundManhal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.only(
                      left: 10, top: 100, right: 10, bottom: 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.category == "words" ? 2 : 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: contentList.length,
                  itemBuilder: (context, index) {
                    ContentModel item = contentList[index];

                    return GestureDetector(
                      onTap: () {
                        if (widget.category == "words" &&
                            selectedCategory == null) {
                          setState(() {
                            selectedCategory = item.id;
                            _fetchContent();
                          });
                        } else {
                          _confirmToggleLock(item);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: _getTileColor(widget.category),
                          image: const DecorationImage(
                            image: AssetImage(
                                "assets/images/ManhalBackground2.png"),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 40,
                                color: Color(0xFF638297),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.isLocked)
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Image.asset(
                                  "assets/images/Lock.png",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

Color _getTileColor(String category) {
  switch (category) {
    case "letters":
    case "words":
      return Colors.blue[200]!.withOpacity(0.8);
    case "numbers":
      return const Color(0xFFF9EAFB);
    case "ethicalValues":
      return Colors.yellow[100]!;
    default:
      return Colors.white;
  }
}

String _getCategoryTitle(String category) {
  switch (category) {
    case "letters":
      return "إدارة الحروف";
    case "numbers":
      return "إدارة الأرقام";
    case "words":
      return "إدارة الكلمات";

    default:
      return "إدارة المحتوى";
  }
}
