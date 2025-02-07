class HomePageModel {
  final String userName;

  /// الإنشاء باستخدام اسم المستخدم
  HomePageModel({required this.userName});

  /// إنشاء كائن من بيانات Firebase (أو مصدر بيانات آخر)
  factory HomePageModel.fromFirebase(Map<String, dynamic> data) {
    return HomePageModel(
      userName: data['name'] ?? 'ضيف', // إذا لم يكن هناك اسم يتم تعيين "ضيف"
    );
  }
}