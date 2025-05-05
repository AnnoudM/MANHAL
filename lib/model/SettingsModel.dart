import 'package:cloud_firestore/cloud_firestore.dart';


class SettingsModel {
  final String title;

  SettingsModel(this.title);

  

}

class SettingsFunctions {
  Future<void> clearPasscode(String parentId) async {
    await FirebaseFirestore.instance
        .collection('Parent')
        .doc(parentId)
        .update({'Passcode': FieldValue.delete()});
  }
}



List<SettingsModel> settingsOptions = [
  SettingsModel('معلوماتي الشخصية'),
  SettingsModel('معلومات الطفل'),
  SettingsModel('الحد اليومي للاستخدام'),
  SettingsModel('إدارة المحتوى'),
  SettingsModel('أطفالي'),
  SettingsModel('متابعة الطفل'),
];
