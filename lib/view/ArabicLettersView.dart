import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../model/ArabicLettersModel.dart';
import '../view/letter_view.dart';
import '../controller/ArabicLettersController.dart';

class ArabicLettersView extends StatefulWidget {
  final String parentId;
  final String childId;

  const ArabicLettersView({
    Key? key,
    required this.parentId,
    required this.childId,
  }) : super(key: key);

  @override
  _ArabicLettersViewState createState() => _ArabicLettersViewState();
}

class _ArabicLettersViewState extends State<ArabicLettersView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> lockedLetters = [];
  final ArabicLettersController _controller = ArabicLettersController();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _fetchLockedLetters();
    _preloadSong();
  }

  Future<void> _fetchLockedLetters() async {
    try {
      lockedLetters =
          await _controller.fetchLockedLetters(widget.parentId, widget.childId);
      setState(() {});
    } catch (e) {
      print("❌ خطأ أثناء جلب الحروف المقفلة: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _preloadSong() async {
    try {
      await _audioPlayer.setUrl(
          "https://firebasestorage.googleapis.com/v0/b/manhal-e2276.firebasestorage.app/o/songs%2F%D8%A3%D9%86%D8%B4%D9%88%D8%AF%D8%A9%20%D8%A7%D9%84%D8%AD%D8%B1%D9%88%D9%81.m4a?alt=media&token=be1f4e78-c8b0-4267-be65-157acd174911");
    } catch (e) {
      print("خطأ في تحميل الصوت: $e");
    }
  }

Future<void> _toggleSong() async {
  if (_audioPlayer.playing) {
    await _audioPlayer.pause(); 
  } else {
    await _audioPlayer.play(); 
  }
  setState(() {}); 
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/BackGroundManhal.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
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
                onPressed: () {
                  _audioPlayer.stop(); // ✅ إيقاف الصوت عند الرجوع
                  Navigator.of(context).pop();
                },
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
                    colorFilter: ColorFilter.mode(
                      Color.fromARGB(102, 0, 0, 0),
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
                      onPressed: _toggleSong, // ✅ تشغيل/إيقاف الصوت عند الضغط
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.2,
                ),
                itemCount: ArabicLettersModel.arabicLetters.length,
                itemBuilder: (context, index) {
                  final letter = ArabicLettersModel.arabicLetters[index];
                  final isLocked = lockedLetters.contains(letter);

                  return GestureDetector(
                    onTap: () {
                      if (!isLocked) {
                        _audioPlayer.stop(); // ✅ إيقاف الصوت

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArabicLetterPage(
                              letter: letter,
                              parentId: widget.parentId, // ✅ تمرير معرف الوالد
                              childId: widget.childId, // ✅ تمرير معرف الطفل),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('هذا الحرف مقفل ولا يمكن الدخول إليه!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blue[100]?.withOpacity(0.8),
                        image: const DecorationImage(
                          image:
                              AssetImage("assets/images/ManhalBackground2.png"),
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
                            letter,
                            textAlign: TextAlign.center,
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
                                fit: BoxFit.contain,
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
      ),
    );
  }
}
