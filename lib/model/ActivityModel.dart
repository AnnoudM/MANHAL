class ActivityModel {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? audioUrl;
  final String? imageUrl; 
  final double progress;

  ActivityModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.audioUrl,
    this.imageUrl, 
    required this.progress,
  });

  // Factory method to create ActivityModel from Firestore document data
  factory ActivityModel.fromFirestore(Map<String, dynamic> data) {
    return ActivityModel(
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
      audioUrl: data['audioUrl'],
      imageUrl: data['imageUrl'], 
      progress: (data['progress'] ?? 0.0).toDouble(),
    );
  }
}