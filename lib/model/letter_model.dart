import 'package:audioplayers/audioplayers.dart';

class LetterModel {
  final List<String> examples;
  final List<String> images;
  final String letterSound;
  final String songUrl;

  LetterModel({
    required this.examples,
    required this.images,
    required this.letterSound,
    required this.songUrl,
  });

  factory LetterModel.fromMap(Map<String, dynamic> map) {
    return LetterModel(
      examples: List<String>.from(map['examples'] ?? []),
      images: List<String>.from(map['image'] ?? []),
      letterSound: map['letterSound'] ?? '',
      songUrl: map['songUrl'] ?? '',
    );
  }
}

Future<void> playAudio(String url) async {
  final player = AudioPlayer();
  await player.play(UrlSource(url));
}
