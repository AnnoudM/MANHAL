import 'package:flutter/material.dart';
import 'number_view.dart';
import '../model/NumbersModel.dart';
import '../controller/NumbersController.dart';
import 'package:flutter_tts/flutter_tts.dart';
import'../controller/HomePageController.dart';

// Helper function to convert English digits to Arabic numeral characters
String convertToArabicNumbers(int number) {
  final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number.toString().split('').map((digit) {
    return arabicDigits[int.parse(digit)];
  }).join('');
}

class ArabicNumberView extends StatefulWidget {
  final String parentId;
  final String childId;

  const ArabicNumberView({
    Key? key,
    required this.parentId,
    required this.childId,
  }) : super(key: key);

  @override
  _ArabicNumberViewState createState() => _ArabicNumberViewState();
}

class _ArabicNumberViewState extends State<ArabicNumberView> {
  final NumbersController _controller = NumbersController();
  List<String> lockedNumbers = [];
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _fetchLockedNumbers();
  }

// Fetch list of locked numbers from Firestore
  Future<void> _fetchLockedNumbers() async {
    lockedNumbers =
        await _controller.fetchLockedNumbers(widget.parentId, widget.childId);
    setState(() {});
  }
// Show popup + TTS when a locked number is tapped
  Future<void> _showLockedPopup(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            "الرقم مقفل",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "لا يمكنك الدخول إليه الآن",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        );
      },
    );

// Set up and speak the Arabic warning message
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setVoice(
        {"name": "Microsoft Naayf - Arabic (Saudi)", "locale": "ar-SA"});
    await flutterTts.setPitch(0.6);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(
        "هٰذَاالرَّقْمُ مُقْفَلٌ. لَا يُمْكِنُكَ الدُّخُولُ إِلَيْهِ الآنَ  ");

    await Future.delayed(const Duration(milliseconds: 500));
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/BackGroundManhal.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              AppBar(
                title: const Text(
                  'لنتعلم الأرقام !',
                  style: TextStyle(
                    fontFamily: 'Blabeloo',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: Colors.black87),
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePageController(
          parentId: widget.parentId,
          childID: widget.childId,
        ),
      ),
    );
  },
),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 400, 
                  height: 90, 
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/NumberBackground.png"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.white54,
                        BlendMode.dstATop,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: const Text(
                    'رحلة الأرقام',
                    style: TextStyle(
                      fontFamily: 'Blabeloo',
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 4 items per row
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: NumbersModel.numbers.length,
                  itemBuilder: (context, index) {
                    final number = NumbersModel.numbers[index];
                    final isLocked = lockedNumbers.contains(number.toString());

                    return GestureDetector(
                      onTap: () {
                        if (!isLocked) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LearnNumberPage(
                                number: number,
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFF9EAFB),
                          image: const DecorationImage(
                            image: AssetImage(
                                "assets/images/ManhalBackground2.png"),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.white10,
                              BlendMode.srcATop,
                            ),
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
                              convertToArabicNumbers(number),
                              style: const TextStyle(
                                fontSize: 50,
                                color: Color(0xFF638297),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isLocked)
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Image.asset(
                                  "assets/images/Lock.png",
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                          ],
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
}
