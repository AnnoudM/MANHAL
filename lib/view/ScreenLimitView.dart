import 'package:flutter/material.dart';
import '../controller/ScreenLimitController.dart';
import '../model/ScreenLimitModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScreenLimitView extends StatefulWidget {
  final String parentId;
  final String childId;

  const ScreenLimitView({Key? key, required this.parentId, required this.childId}) : super(key: key);

  @override
  _ScreenLimitViewState createState() => _ScreenLimitViewState();
}

class _ScreenLimitViewState extends State<ScreenLimitView> {
  final ScreenLimitController _controller = ScreenLimitController();
  bool isLimitEnabled = false;
  String? selectedStartTime;
  String? selectedEndTime;

  final List<String> timeOptions = List.generate(48, (index) {
    int hour = index ~/ 2;
    int minute = (index % 2) * 30;
    String formatted12Hour = ScreenLimitModel.formatTimeToDisplay("$hour:${minute.toString().padLeft(2, '0')}");
    return formatted12Hour;
  });

  @override
  void initState() {
    super.initState();
    _loadUsageLimit();
  }

  // fetch usage time from Firestore
  void _loadUsageLimit() async {
    var usageLimit = await _controller.getUsageLimit(widget.parentId, widget.childId);
    if (usageLimit != null) {
      setState(() {
        isLimitEnabled = true;
        selectedStartTime = ScreenLimitModel.formatTimeToDisplay(usageLimit['startTime']);
        selectedEndTime = ScreenLimitModel.formatTimeToDisplay(usageLimit['endTime']);
      });
    }
  }

  // confirm and save new time range
  void _saveLimit() {
    if (selectedStartTime == null || selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("يجب اختيار وقت البداية والنهاية", style: TextStyle(fontFamily: "alfont")),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String startTime24 = ScreenLimitModel.formatTimeToStorage(selectedStartTime!);
    String endTime24 = ScreenLimitModel.formatTimeToStorage(selectedEndTime!);

    if (startTime24 == endTime24) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("إلغاء الحد الزمني", style: TextStyle(fontFamily: "alfont")),
          content: Text(
            "لقد اخترت وقتًا يغطي 24 ساعة، لذلك لا يوجد حد زمني.\nهل أنت متأكد من أنك تريد إلغاء تجديد وقت الاستخدام؟",
            style: TextStyle(fontFamily: "alfont"),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("إلغاء", style: TextStyle(fontFamily: "alfont")),
            ),
            TextButton(
              onPressed: () {
                _controller.deleteUsageLimit(widget.parentId, widget.childId);
                setState(() {
                  isLimitEnabled = false;
                  selectedStartTime = null;
                  selectedEndTime = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("تم إلغاء الحد الزمني بنجاح!", style: TextStyle(fontFamily: "alfont")),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text("تأكيد", style: TextStyle(fontFamily: "alfont")),
            ),
          ],
        ),
      );
      return;
    }

    String durationText = _controller.calculateDuration(startTime24, endTime24);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تأكيد حفظ الحد الزمني", style: TextStyle(fontFamily: "alfont")),
        content: Text(
          "هل أنت متأكد أنك تريد تحديد وقت لطفلك من $selectedStartTime إلى $selectedEndTime؟ (والتي مدتها $durationText)",
          style: TextStyle(fontFamily: "alfont"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء", style: TextStyle(fontFamily: "alfont")),
          ),
          TextButton(
            onPressed: () {
              _controller.saveUsageLimit(
                parentId: widget.parentId,
                childId: widget.childId,
                startTime: startTime24,
                endTime: endTime24,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("تم حفظ الحد الزمني بنجاح!", style: TextStyle(fontFamily: "alfont")),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: Text("تأكيد", style: TextStyle(fontFamily: "alfont")),
          ),
        ],
      ),
    );
  }

  // confirm and delete limit
  void _deleteLimit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تأكيد الحد الزمني", style: TextStyle(fontFamily: "alfont")),
        content: Text("هل أنت متأكد أنك تريد حذف تحديد ساعات الطفل؟", style: TextStyle(fontFamily: "alfont")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء", style: TextStyle(fontFamily: "alfont")),
          ),
          TextButton(
            onPressed: () {
              _controller.deleteUsageLimit(widget.parentId, widget.childId);
              setState(() {
                isLimitEnabled = false;
                selectedStartTime = null;
                selectedEndTime = null;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("تم حذف الحد الزمني بنجاح!", style: TextStyle(fontFamily: "alfont")),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.pop(context);
            },
            child: Text("تأكيد", style: TextStyle(fontFamily: "alfont")),
          ),
        ],
      ),
    );
  }

  // time dropdown input
  Widget _buildDropdown({
    required String? value,
    required String hintText,
    String? noteText,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border.all(color: Colors.grey.shade400, width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Center(
            child: Text(
              hintText,
              style: TextStyle(fontFamily: "alfont", color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: Icon(Icons.arrow_drop_down),
          style: TextStyle(fontFamily: "alfont", color: Colors.black),
          onChanged: onChanged,
          selectedItemBuilder: (BuildContext context) {
            return timeOptions.map((time) {
              return Center(
                child: Text(
                  time,
                  style: TextStyle(fontFamily: "alfont"),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList();
          },
          items: timeOptions.map((time) {
            String label = time;
            if (noteText != null && noteText == time) {
              label += time == selectedStartTime ? " (وقت البداية)" : " (وقت النهاية)";
            }

            return DropdownMenuItem<String>(
              value: time,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: "alfont",
                          fontWeight: noteText == time ? FontWeight.bold : FontWeight.normal,
                          color: noteText == time ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("تحديد وقت الاستخدام", style: TextStyle(fontFamily: "alfont", fontSize: 28)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/BackGroundManhal.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "تحديد ساعات الطفل",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: "alfont",
                        ),
                      ),
                      Switch(
                        value: isLimitEnabled,
                        onChanged: (value) {
                          if (!value) {
                            _deleteLimit();
                          } else {
                            setState(() {
                              isLimitEnabled = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    "عند تفعيل هذا الزر، ستتمكن من تحديد الأوقات المتاحة لطفلك لاستخدام التطبيق.",
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: "alfont"),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 20),
                  if (isLimitEnabled)
                    Column(
                      children: [
                        _buildDropdown(
                          value: selectedStartTime,
                          hintText: "اختر وقت البداية",
                          noteText: selectedEndTime,
                          onChanged: (value) => setState(() => selectedStartTime = value),
                        ),
                        SizedBox(height: 20),
                        _buildDropdown(
                          value: selectedEndTime,
                          hintText: "اختر وقت النهاية",
                          noteText: selectedStartTime,
                          onChanged: (value) => setState(() => selectedEndTime = value),
                        ),
                        SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveLimit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("حفظ", style: TextStyle(color: Colors.white, fontFamily: "alfont")),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
