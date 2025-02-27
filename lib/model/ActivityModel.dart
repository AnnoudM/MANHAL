class ActivityModel {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? audioUrl;
  final String? imageUrl; // ✅ تمت إضافة دعم الصورة
  final double progress;

  ActivityModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.audioUrl,
    this.imageUrl, // ✅ إضافة الصورة كمتغير قابل للاختبار
    required this.progress,
  });

  // تحويل بيانات Firestore إلى ActivityModel
  factory ActivityModel.fromFirestore(Map<String, dynamic> data) {
    return ActivityModel(
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
      audioUrl: data['audioUrl'],
      imageUrl: data['imageUrl'], // ✅ جلب الصورة من Firestore إذا كانت موجودة
      progress: (data['progress'] ?? 0.0).toDouble(),
    );
  }
}