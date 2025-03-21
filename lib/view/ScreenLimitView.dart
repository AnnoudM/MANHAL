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

  /// ✅ قائمة الأوقات بصيغة 12 ساعة ولكن يتم تخزينها بصيغة 24 ساعة
  final List<String> timeOptions = List.generate(
      48,
      (index) {
        int hour = index ~/ 2;
        int minute = (index % 2) * 30;
        String formatted12Hour = ScreenLimitModel.formatTimeToDisplay("$hour:${minute.toString().padLeft(2, '0')}");
        return formatted12Hour;
      });

  /// ✅ جلب الحد الزمني من Firebase عند فتح الصفحة
  @override
  void initState() {
    super.initState();
    _loadUsageLimit();
  }

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

  /// ✅ حفظ الحد الزمني مع تأكيد
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تأكيد حفظ الوقت", style: TextStyle(fontFamily: "alfont")),
        content: Text(
          "هل أنت متأكد أنك تريد تحديد وقت لطفلك من $selectedStartTime إلى $selectedEndTime؟",
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

  /// ✅ حذف الحد الزمني مع تأكيد
  void _deleteLimit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تأكيد حذف الوقت", style: TextStyle(fontFamily: "alfont")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,  // يجعل خلفية الـ AppBar تمتد خلف المحتوى
      appBar: AppBar(
       
          title: Text("تحديد وقت الاستخدام", style: TextStyle(fontFamily: "alfont")),
        centerTitle: true,
        backgroundColor: Colors.transparent,  // خلفية شفافة للـ AppBar
        elevation: 0,  // لإزالة الظل الذي يظهر تحت الـ AppBar
      ),
      body: Stack(
        children: [
          // صورة الخلفية التي تغطي كامل الصفحة
          Positioned.fill(
            child: Image.asset(
              'assets/images/BackGroundManhal.jpg',
              fit: BoxFit.cover,  // يجعل الصورة تغطي كامل الشاشة
            ),
          ),
          // المحتوى الذي سيتم عرضه فوق الصورة
          SafeArea(  // استخدام SafeArea لتجنب التداخل مع الـ AppBar
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
                    "عند تفعيل هذا الزر، ستتمكن من تحديد الأوقات المتاحة لطفلك لاستخدام التطبيق. ",
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: "alfont"),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 20),
                  if (isLimitEnabled)
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: DropdownButton<String>(
                            value: selectedStartTime,
                            hint: Text("اختر وقت البداية", style: TextStyle(fontFamily: "alfont")),
                            isExpanded: true,
                            items: timeOptions
                                .map((time) => DropdownMenuItem(
                                      value: time,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                                        ),
                                        child: Center(child: Text(time, style: TextStyle(fontFamily: "alfont"))),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedStartTime = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: DropdownButton<String>(
                            value: selectedEndTime,
                            hint: Text("اختر وقت النهاية", style: TextStyle(fontFamily: "alfont")),
                            isExpanded: true,
                            items: timeOptions
                                .map((time) => DropdownMenuItem(
                                      value: time,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                                        ),
                                        child: Center(child: Text(time, style: TextStyle(fontFamily: "alfont"))),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedEndTime = value;
                              });
                            },
                          ),
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