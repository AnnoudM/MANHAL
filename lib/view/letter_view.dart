import 'package:flutter/material.dart';
import '../controller/letter_controller.dart';
import '../model/letter_model.dart';

class ArabicLetterPage extends StatefulWidget {
  final String letter;

  const ArabicLetterPage({super.key, required this.letter});

  @override
  _ArabicLetterPageState createState() => _ArabicLetterPageState();
}

class _ArabicLetterPageState extends State<ArabicLetterPage> {
  final LetterController _controller = LetterController();
  LetterModel? letterData;
  bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      LetterModel data = await _controller.fetchData(widget.letter);
      setState(() {
        letterData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("حدث خطأ أثناء تحميل البيانات: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildTopSection(),
                  const SizedBox(height: 20),
                  if (letterData?.songUrl != null) _buildSongSection(),
                  const SizedBox(height: 20),
                  _buildNextButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffD1E3F1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF3F414E).withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward,
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
                  widget.letter,
                  style: const TextStyle(
                    fontSize: 120,
                    color: Color(0xFF3F414E),
                    fontFamily: 'Blabeloo',
                  ),
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: Image.asset(
                    "assets/images/high-volume.png",
                  ),
                  iconSize: 72, // تحديد حجم الأيقونة
                  padding: EdgeInsets.zero, // إزالة المسافة الداخلية
                  constraints: const BoxConstraints(
                  ),
                  onPressed: () {
                    if (letterData?.letterSound != null) {
                      _controller.speak(letterData!.letterSound);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < letterData!.examples.length; i++)
            _buildExampleContainer(i),
        ],
      ),
    );
  }

  Widget _buildExampleContainer(int index) {
    return Container(
      height: 100,
      width: 343,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffE7F4FF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Image.asset(
              "assets/images/high-volume.png",
              width: 40,
              height: 40,
            ),
            onPressed: () {
              _controller.speak(letterData!.examples[index]);
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                letterData!.examples[index],
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 40,
                    color: Color(0xFF3F414E),
                    fontFamily: "Blabeloo"),
              ),
            ),
          ),
          if (letterData!.images.length > index)
            Image.network(
              letterData!.images[index],
              height: 80,
              width: 80,
            ),
        ],
      ),
    );
  }

  Widget _buildSongSection() {
    return Container(
      height: 73,
      width: 345,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage("assets/images/Letters.png"),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Color.fromARGB(102, 0, 0, 0), BlendMode.dstATop),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Image.asset(
              "assets/images/high-volume.png",
              width: 40,
              height: 40,
            ),
            onPressed: () {
              _controller.speak(letterData!.songUrl);
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                "الأنشودة",
                style: const TextStyle(
                    fontSize: 32,
                    fontFamily: "Blabeloo",
                    fontWeight: FontWeight.bold,
                    color: Color(0xff3F414E)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: 289,
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffD1E3F1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          children: const [
            Icon(Icons.arrow_back, size: 34, color: Color(0xFF3F414E)),
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
    );
  }
}
