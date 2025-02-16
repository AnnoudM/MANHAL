import 'package:flutter/material.dart';
import '../controller/EthicalValueController.dart';
import '../model/EthicalValueModel.dart';
import 'package:manhal/view/EthicalVideoView.dart';

class EthicalValueView extends StatefulWidget {
  final String parentId;
  final String childId;

  const EthicalValueView({Key? key, required this.parentId, required this.childId}) : super(key: key);

  @override
  _EthicalValueViewState createState() => _EthicalValueViewState();
}

class _EthicalValueViewState extends State<EthicalValueView> {
  final EthicalValueController _ethicalController = EthicalValueController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 🔹 الخلفية (تغطي الشاشة بالكامل)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackGroundManhal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 المسار (نزوله للأسفل وتقليل ميلانه)
          Positioned(
            top: 160, // نزوله شوي تحت
            left: MediaQuery.of(context).size.width * 0.08, // تقليل الميلان لليسار
            width: MediaQuery.of(context).size.width * 0.5, // تصغير الحجم قليلاً
            child: Image.asset("assets/images/Pathway.png", fit: BoxFit.contain),
          ),

          // 🔹 القيم الأخلاقية مرتبة على المسار
          StreamBuilder<int?>(
            stream: _ethicalController.fetchChildLevel(widget.parentId, widget.childId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              int childLevel = snapshot.data ?? 1;

              List<String> ethicalValues = [
                "الصدق",
                "الأمانة",
                "التعاون",
                "الإحسان",
                "الشجاعة",
                "التواضع"
              ];

              return Stack(
                children: ethicalValues.asMap().entries.map((entry) {
                  int level = entry.key + 1;
                  String name = entry.value;
                  bool isUnlocked = level <= childLevel;
                  double positionTop = _getPositionForLevel(level) + 85; // نزول القيم تحت الPathway
                  double positionLeft = _getLeftPositionForLevel(level) - 20;

                  return Positioned(
                    top: positionTop,
                    left: positionLeft,
                    child: GestureDetector(
                      onTap: isUnlocked
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EthicalVideoView(
                                    parentId: widget.parentId,
                                    childId: widget.childId,
                                    ethicalValue: EthicalValueModel.fromName(name, level),
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 🔹 الدائرة الخاصة بالقيمة
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,color: isUnlocked ? Colors.white : Colors.grey.shade300,
                              border: Border.all(
                                color: isUnlocked ? Colors.orange : Colors.grey,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? Colors.black : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                          // 🔹 أيقونة القفل تبقى كما هي
                          if (!isUnlocked)
                            const Positioned(
                              bottom: 8,
                              right: 8,
                              child: Icon(Icons.lock, color: Colors.red, size: 22),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // 🔹 الكأس في الأعلى مع الكتكوت
          Positioned(
            top: 50,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: Image.asset("assets/images/trophy.png", width: 100),
          ),
          Positioned(
            top: 60,
            right: 30,
            child: Image.asset("assets/images/happyChick.png", width: 70),
          ),

          // 🔹 شخصية الكتكوت في البداية
          Positioned(
            bottom: 110,
            left: 20,
            child: Image.asset("assets/images/chick.png", width: 70),
          ),

          // 🔹 "البداية" تحت المسار مع ترك مساحة كافية
          Positioned(
            bottom: 70,
            right: MediaQuery.of(context).size.width * 0.6,
            child: Text(
              "البداية",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 تحديد مواضع القيم الأخلاقية على المسار بدقة (بعد Pathway شوي)
  double _getPositionForLevel(int level) {
    switch (level) {
      case 1: return 580; // الصدق
      case 2: return 475; // الأمانة (زيادة المسافة)
      case 3: return 375; // التعاون
      case 4: return 265; // الإحسان (زيادة المسافة)
      case 5: return 165; // الشجاعة
      case 6: return 80; // التواضع (زيادة المسافة)
      default: return 580;
    }
  }

  // 🔹 تحديد الإزاحة الأفقية لكل قيمة لضبط المحاذاة مع المسار
  double _getLeftPositionForLevel(int level) {
    switch (level) {
      case 1: return 110; // الصدق - يسار أكثر
      case 2: return 190; // الأمانة - يمين أكثر
      case 3: return 100; // التعاون - يسار أكثر
      case 4: return 200; // الإحسان - يمين أكثر
      case 5: return 120; // الشجاعة - يسار أكثر
      case 6: return 210; // التواضع - يمين أكثر
      default: return 140;
    }
  }
}