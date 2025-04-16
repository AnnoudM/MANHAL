import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // For Text-to-Speech functionality
import '../controller/NumbersController.dart';
import 'package:manhal/view/ActivityView.dart'; // تأكد من صحة الاستيراد

class LearnNumberPage extends StatefulWidget {
  final int number; // Receive the selected number
  final String parentId; // ✅ إضافة معرف الوالد
  final String childId;  // ✅ إضافة معرف الطفل

 const LearnNumberPage({
    super.key, 
    required this.number,
    required this.parentId,  // ✅ إضافة معرف الوالد
    required this.childId,   // ✅ إضافة معرف الطفل
  });

  @override
  _LearnNumberPageState createState() => _LearnNumberPageState();
}

class _LearnNumberPageState extends State<LearnNumberPage> {
  final FlutterTts flutterTts = FlutterTts(); // TTS instance
  final NumbersController _controller = NumbersController();
  Map<String, dynamic>? numberData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch data from Firebase
  void fetchData() async {
    try {
      final data = await _controller.fetchData(widget.number);
      setState(() {
        numberData = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  // Function to speak the number in Arabic
  void _speakNumber() async {
    if (numberData != null && numberData!['arabic_word'] != null) {
      await flutterTts.setLanguage("ar-SA"); // Set language to Arabic
      await flutterTts.speak(numberData!['arabic_word']); // Speak from Firebase data
    } else {
      print("No Arabic word available to speak.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator())
              : numberData == null
                  ? Center(child: Text('❌ لا توجد بيانات لهذا الرقم'))
                  : Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: Color(0xFFF9EAFB),
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  numberData?['arabic_numeral'] ?? '-',
                                  style: TextStyle(
                                    fontSize: 200,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'Blabeloo',
                                  ),
                                ),
                                SizedBox(height: 20),
                                GestureDetector(
                                  onTap: _speakNumber,
                                  child: Image.asset(
                                    'assets/images/high-volume.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              SizedBox(height: 5),
Expanded(
  flex: 3,
  child: Center(
    child: SizedBox(
      height: widget.number == 1
    ? MediaQuery.of(context).size.height * 0.3
    : MediaQuery.of(context).size.height * 0.25,
      child: SingleChildScrollView(
child: Center(
  child: (numberData?['images'] as List).length == 1
      ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (numberData!['images'] as List).map((imageUrl) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: SizedBox(
                width: 180,
                height: 180,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }).toList(),
        )
      : Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: (numberData!['images'] as List).map((imageUrl) {
            return SizedBox(
              width: 80,
              height: 80,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            );
          }).toList(),
        ),
),



      ),
    ),
  ),
),

                              ],
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ActivityView(
                                     parentId: widget.parentId,  // ✅ تمرير معرف الوالد
                                     childId: widget.childId,    // ✅ تمرير معرف الطفل
                                    value: widget.number.toString(),
                                    type: "number",
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: Color(0xFFF9EAFB),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back, color: Colors.black),
                                  SizedBox(width: 10),
                                  Text(
                                    "التالي",
                                    style: TextStyle(
                                        fontSize: 40,
                                        color: Colors.black,
                                        fontFamily: 'Blabeloo'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          // زر الرجوع في الزاوية العلوية اليمنى
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
}
