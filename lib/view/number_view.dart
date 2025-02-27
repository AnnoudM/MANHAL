import 'package:flutter/material.dart'; 
import 'package:flutter_tts/flutter_tts.dart'; // For Text-to-Speech functionality
import '../controller/NumbersController.dart';
import 'package:manhal/view/ActivityView.dart'; // تأكد من صحة الاستيراد

class LearnNumberPage extends StatefulWidget {
  final int number; // Receive the selected number
  const LearnNumberPage({super.key, required this.number});

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
      backgroundColor: Colors.white, // Top part white
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : numberData == null
              ? Center(child: Text('❌ لا توجد بيانات لهذا الرقم'))
              : Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Color(0xFFF9EAFB), // Light pink background for the main content
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              numberData?['arabic_numeral'] ?? '-', // Dynamic Arabic numeral
                              style: TextStyle(
                                fontSize: 200, // Larger font size
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Blabeloo',
                              ),
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: _speakNumber, // Trigger the sound on tap
                              child: Image.asset(
                                'assets/images/high-volume.png', // Sound icon from assets
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 30),
                            Expanded(
                              flex: 3,
                              child: SingleChildScrollView(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: numberData?['images'] != null
                                      ? (numberData!['images'] as List).map((imageUrl) {
                                          return Container(
                                            width: 80, // تقليل الحجم تلقائيًا
                                            height: 80,
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.contain,
                                            ),
                                          );
                                        }).toList()
                                      : [
                                          Icon(Icons.image_not_supported, size: 100),
                                        ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white, // Bottom white background
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: InkWell(
                        onTap: () {
                     
                          // عند الضغط، ينتقل إلى صفحة ActivityView مع تمرير رقم الصفحة الحالي ونوع "number"
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityView(
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
                            color: Color(0xFFF9EAFB), // Light pink button color
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, color: Colors.black),
                              SizedBox(width: 10),
                              Text(
                                "التالي", // Arabic for "Next"
                                style: TextStyle(
                                    fontSize: 40, color: Colors.black, fontFamily: 'Blabeloo'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}