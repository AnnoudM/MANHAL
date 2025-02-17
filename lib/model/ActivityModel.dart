class ActivityModel {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String audioUrl;
  final double progress;

  ActivityModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.audioUrl,
    required this.progress,
  });

  // تحويل nkjالبياناتjjjjkkjFirestore إلى ActivityModel
  factory ActivityModel.fromFirestore(Map<String, dynamic> data) {
    return ActivityModel(
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      progress: (data['progress'] ?? 0.0).toDouble(),
    );
  }
}