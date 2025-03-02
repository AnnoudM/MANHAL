class ScreenLimitModel {
  String startTime; // بصيغة 24 ساعة (HH:mm)
  String endTime; // بصيغة 24 ساعة (HH:mm)

  ScreenLimitModel({required this.startTime, required this.endTime});

  /// ✅ تحويل بيانات Firebase إلى كائن Model
  factory ScreenLimitModel.fromMap(Map<String, dynamic> data) {
    return ScreenLimitModel(
      startTime: data['startTime'],
      endTime: data['endTime'],
    );
  }

  /// ✅ تحويل كائن Model إلى Map لحفظه في Firebase
  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  /// ✅ تحويل وقت بصيغة 24 ساعة إلى 12 ساعة لعرضه في الواجهة
  static String formatTimeToDisplay(String time24) {
    List<String> parts = time24.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    String period = hour < 12 ? "صباحًا" : "مساءً";
    int displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return "$displayHour:${minute == 0 ? '00' : '30'} $period";
  }

  /// ✅ تحويل وقت بصيغة 12 ساعة إلى 24 ساعة لحفظه في Firebase
  static String formatTimeToStorage(String displayTime) {
    RegExp regex = RegExp(r"(\d+):(\d+) (صباحًا|مساءً)");
    Match? match = regex.firstMatch(displayTime);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      bool isPM = match.group(3) == "مساءً";

      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    }

    return "00:00"; // Default case
  }
}