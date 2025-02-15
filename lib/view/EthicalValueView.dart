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
      appBar: AppBar(title: const Text("القيم الأخلاقية")),
      body: StreamBuilder<int?>(
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
            children: [
              // 🔹 الخلفية
              Positioned.fill(
                child: Image.asset("assets/images/learningPath.jpg", fit: BoxFit.cover),
              ),

              // 🔹 القيم الأخلاقية موضوعة على المسار الصحيح
              ...ethicalValues.asMap().entries.map((entry) {
                int level = entry.key + 1;
                String name = entry.value;
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
                                  ethicalValue: EthicalValueModel.fromName(name, level),
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isUnlocked ? Colors.green.shade300 : Colors.grey,
                          ),
                          child: Center(
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        if (!isUnlocked)
                          const Positioned(
                            bottom: 8,
                            right: 8,
                            child: Icon(Icons.lock, color: Colors.white, size: 24),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }// 🔹 وظيفة لحساب المواضع الصحيحة لكل قيمة على المسار
  double _getPositionForLevel(int level) {
    switch (level) {
      case 1:
        return 500; // الصدق
      case 2:return 420; // الأمانة
      case 3:
        return 350; // التعاون
      case 4:
        return 270; // الإحسان
      case 5:
        return 200; // الشجاعة
      case 6:
        return 120; // التواضع
      default:
        return 500;
    }
  }

  // 🔹 وظيفة لحساب الإزاحة الأفقية لكل قيمة
  double _getLeftPositionForLevel(int level) {
    switch (level) {
      case 1:
        return 130; // الصدق
      case 2:
        return 160; // الأمانة
      case 3:
        return 130; // التعاون
      case 4:
        return 160; // الإحسان
      case 5:
        return 130; // الشجاعة
      case 6:
        return 160; // التواضع
      default:
        return 130;
    }
  }
}