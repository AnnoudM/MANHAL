class SettingsModel {
  final String title;

  SettingsModel(this.title);
}

// هذه القائمة تمثل خيارات الإعدادات
List<SettingsModel> settingsOptions = [
  SettingsModel('معلوماتي الشخصية'),
  SettingsModel('معلومات الطفل'),
  SettingsModel('الحد اليومي للاستخدام'),
  SettingsModel('إدارة المحتوى'),
  SettingsModel('أطفالي'),
];
