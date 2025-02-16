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
          // 🔹 الخلفية
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
            top: 160, 
            left: MediaQuery.of(context).size.width * 0.08, 
            width: MediaQuery.of(context).size.width * 0.5, 
            child: Image.asset("assets/images/Pathway.png", fit: BoxFit.contain),
          ),

          // 🔹 القيم الأخلاقية من Firestore
          StreamBuilder<int?>(
            stream: _ethicalController.fetchChildLevel(widget.parentId, widget.childId),
            builder: (context, childSnapshot) {
              if (!childSnapshot.hasData) return const Center(child: CircularProgressIndicator());
              int childLevel = childSnapshot.data ?? 1;

              return StreamBuilder<List<EthicalValueModel>>(
                stream: _ethicalController.fetchEthicalValues(childLevel), // 🔹 جلب القيم الأخلاقية من Firestore
                builder: (context, valueSnapshot) {
                  if (!valueSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                  List<EthicalValueModel> ethicalValues = valueSnapshot.data!;

                  return Stack(
                    children: ethicalValues.map((ethicalValue) {
                      int level = ethicalValue.level;
                      bool isUnlocked = level <= childLevel;
                      double positionTop = _getPositionForLevel(level);
                      double positionLeft = _getLeftPositionForLevel(level);

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
                                        ethicalValue: ethicalValue, // 🔹 تمرير بيانات القيمة المختارة
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
                                width: 80,height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isUnlocked ? Colors.white : Colors.grey.shade300,
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
                                    ethicalValue.name, // 🔹 الاسم من Firestore
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isUnlocked ? Colors.black : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                              // 🔹 أيقونة القفل
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

          // 🔹 "البداية" تحت المسار
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

  // 🔹 تحديد مواضع القيم الأخلاقية على المسار
  double _getPositionForLevel(int level) {
    switch (level) {
      case 1: return 580;
      case 2: return 475;
      case 3: return 375;
      case 4: return 265;
      case 5: return 165;
      case 6: return 80;
      default: return 580;
    }
  }

  // 🔹 تحديد الإزاحة الأفقية لكل قيمة لضبط المحاذاة مع المسار
  double _getLeftPositionForLevel(int level) {
    switch (level) {
      case 1: return 110;
      case 2: return 190;
      case 3: return 100;
      case 4: return 200;
      case 5: return 120;
      case 6: return 210;
      default: return 140;
    }
  }
}