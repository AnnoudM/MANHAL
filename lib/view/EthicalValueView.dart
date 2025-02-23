import 'package:flutter/material.dart';
import 'dart:async';
import 'package:manhal/controller/EthicalValueController.dart';
import 'package:manhal/model/EthicalValueModel.dart';
import 'package:manhal/view/EthicalVideoView.dart';

class EthicalValueView extends StatefulWidget {
  final String parentId;
  final String childId;

  const EthicalValueView({Key? key, required this.parentId, required this.childId}) : super(key: key);

  @override
  _EthicalValueViewState createState() => _EthicalValueViewState();
}

class _EthicalValueViewState extends State<EthicalValueView> with TickerProviderStateMixin {
  final EthicalValueController _ethicalController = EthicalValueController();
  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ إعداد أنيميشن القفز للكتكوت
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _jumpAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _jumpController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _jumpController.dispose();
    super.dispose();
  }

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
          ),

          // 🔹 زر الرجوع والعنوان العلوي
          Positioned(
            top: 40, // ✅ تعديل المسافة العلوية
            left: 10,
            right: 10,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "القيم الأخلاقية",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BLabeloo',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 40), // ✅ محاذاة للوسط
                  ],
                ),
                const SizedBox(height: 10), // ✅ مسافة بين العنوان والمحتوى
              ],
            ),
          ),

          // 🔹 الكأس
          Positioned(
            top: 80, // ✅ تعديل المسافة بعد العنوان
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: Image.asset("assets/images/trophy.png", width: 90),
          ),

          // 🔹 المسار
          Positioned(
            top: 180, // ✅ تعديل المسافة بعد الكأس
            left: MediaQuery.of(context).size.width * 0.08,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Image.asset("assets/images/Pathway.png", fit: BoxFit.contain),
          ),

          // 🔹 استرجاع مستوى الطفل والقيم الأخلاقية
          StreamBuilder<int?>(
            stream: _ethicalController.fetchChildLevel(widget.parentId, widget.childId),
            builder: (context, levelSnapshot) {
              if (!levelSnapshot.hasData) return const Center(child: CircularProgressIndicator());
              int childLevel = levelSnapshot.data ?? 1;

              return StreamBuilder<List<EthicalValueModel>>(
                stream: _ethicalController.fetchAllEthicalValues(),
                builder: (context, valuesSnapshot) {
                  if (!valuesSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                  List<EthicalValueModel> ethicalValues = valuesSnapshot.data ?? [];return Stack(
                    children: [
                      // ✅ وضع القيم الأخلاقية على المسار
                      ...ethicalValues.map((ethicalValue) {
                        bool isUnlocked = ethicalValue.level <= childLevel;
                        double positionTop = _getPositionForLevel(ethicalValue.level) + 85;
                        double positionLeft = _getLeftPositionForLevel(ethicalValue.level) - 20;

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
                                          ethicalValue: ethicalValue,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isUnlocked ? Colors.white : Colors.grey.shade300,
                                    border: Border.all(
                                      color: isUnlocked ? Colors.orange : Colors.grey,
                                      width: 3,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      ethicalValue.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isUnlocked ? Colors.black : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),

                                // ✅ إضافة القفل فقط للقيم المغلقة
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

                      // ✅ وضع الكتكوت المتحرك حسب مستوى الطفل
                      AnimatedBuilder(
                        animation: _jumpController,
                        builder: (context, child) {
                          return Positioned(
                            top: _getPositionForLevel(childLevel) + _jumpAnimation.value + 90,
                            left: _getLeftPositionForLevel(childLevel) - 90, // ✅ جعله أكثر إلى اليسار
                            child: Image.asset(
                              childLevel >= 7 ? "assets/images/happyChick.png" : "assets/images/chick.png",
                              width: 70,
                            ),
                          );
                        },
                      ),
                    ],);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  double _getPositionForLevel(int level) {
    switch (level) {
      case 1:
        return 600;
      case 2:
        return 495;
      case 3:
        return 395;
      case 4:
        return 285;
      case 5:
        return 185;
      case 6:
      case 7: // ✅ مستوى 7 نفس موقع مستوى 6
        return 100;
      default:
        return 600;
    }
  }

  double _getLeftPositionForLevel(int level) {
    switch (level) {
      case 1:
        return 110;
      case 2:
        return 190;
      case 3:
        return 100;
      case 4:
        return 200;
      case 5:
        return 120;
      case 6:
      case 7: // ✅ مستوى 7 نفس موقع مستوى 6
        return 210;
      default:
        return 140;
    }
  }
}