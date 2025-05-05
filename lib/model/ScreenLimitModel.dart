class ScreenLimitModel {
  String startTime; // 24-hour format (HH:mm)
  String endTime;   // 24-hour format (HH:mm)

  ScreenLimitModel({required this.startTime, required this.endTime});

  // create model instance from Firestore data
  factory ScreenLimitModel.fromMap(Map<String, dynamic> data) {
    return ScreenLimitModel(
      startTime: data['startTime'],
      endTime: data['endTime'],
    );
  }

  // convert model to Map for saving in Firestore
  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  // convert English numbers to Arabic
  static String _convertToArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }

    return input;
  }

  // convert 24-hour time to 12-hour format with Arabic numbers
  static String formatTimeToDisplay(String time24) {
    List<String> parts = time24.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    String period = hour < 12 ? "صباحًا" : "مساءً";
    int displayHour = hour % 12 == 0 ? 12 : hour % 12;
    String formatted = "$displayHour:${minute == 0 ? '00' : '30'} $period";

    return _convertToArabicNumbers(formatted);
  }

  // convert Arabic numbers to English
  static String _convertToEnglishNumbers(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    for (int i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }

    return input;
  }

  // convert 12-hour display time to 24-hour English format
  static String formatTimeToStorage(String displayTime) {
    displayTime = _convertToEnglishNumbers(displayTime);

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

    return "00:00";
  }
}
