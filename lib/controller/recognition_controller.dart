import 'dart:convert';
import 'package:http/http.dart' as http;

class RecognitionController {
  static Future<String?> recognizeText(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.11.248:5000/recognize'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("🔹 Response from server: $responseBody"); // ✅ طباعة الاستجابة للتحقق

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseBody);
        return jsonResponse['text'];
      } else {
        print("❌ Error: ${response.statusCode} - $responseBody");
      }
    } catch (e) {
      print("❌ Exception while sending image: $e");
    }
    return null;
  }
}
