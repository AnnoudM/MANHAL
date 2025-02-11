import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../model/ArabicLettersModel.dart';

class ArabicLettersView extends StatefulWidget {
  const ArabicLettersView({Key? key}) : super(key: key);

  @override
  _ArabicLettersViewState createState() => _ArabicLettersViewState();
}

class _ArabicLettersViewState extends State<ArabicLettersView> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSong() async {
    try {
      await _audioPlayer.setUrl(
          "https://firebasestorage.googleapis.com/v0/b/manhal-e2276.appspot.com/o/songs%2Fأنشودة%20الحروف.m4a?alt=media");
      await _audioPlayer.play();
    } catch (e) {
      print("خطأ في تشغيل الصوت: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
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
                  'لنتعلم الحروف !',
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/Letters.png"),
                      fit: BoxFit.cover,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'أنشودة الحروف',
                        style: TextStyle(
                          fontFamily: 'Blabeloo',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: Image.asset(
                          "assets/images/high-volume.png",
                          width: 30,
                          height: 30,
                        ),
                        onPressed: _playSong, // Calls function to play audio
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 🔥 Now 3 items per row
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: ArabicLettersModel.arabicLetters.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1E3F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          ArabicLettersModel.arabicLetters[index],
                          style: const TextStyle(
                            fontFamily: 'Blabeloo',
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
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
