import 'package:flutter/material.dart';
import '../controller/ScreenLimitController.dart';

class ScreenLimitView extends StatefulWidget {
  final String parentId;
  final String childId;

  const ScreenLimitView({Key? key, required this.parentId, required this.childId}) : super(key: key);

  @override
  _ScreenLimitViewState createState() => _ScreenLimitViewState();
}

class _ScreenLimitViewState extends State<ScreenLimitView> {
  final ScreenLimitController _controller = ScreenLimitController();
  String? selectedStartTime;
  String? selectedEndTime;

  List<String> timeOptions = [
    "08:00",
    "09:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
    "18:00",
    "19:00",
    "20:00",
  ];

  void _saveLimit() {
    if (selectedStartTime != null && selectedEndTime != null) {
      _controller.saveUsageLimit(
        parentId: widget.parentId,
        childId: widget.childId,
        startTime: selectedStartTime!,
        endTime: selectedEndTime!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم حفظ الحد الزمني بنجاح!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تحديد وقت الاستخدام")),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedStartTime,
            hint: Text("اختر وقت البداية"),
            items: timeOptions.map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
            onChanged: (value) {
              setState(() {
                selectedStartTime = value;
              });
            },
          ),
          DropdownButton<String>(
            value: selectedEndTime,
            hint: Text("اختر وقت النهاية"),
            items: timeOptions.map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
            onChanged: (value) {
              setState(() {
                selectedEndTime = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: _saveLimit,
            child: Text("حفظ"),
          ),
        ],
      ),
    );
  }
}