class EthicalValueModel {
  final String name;
  final int level;
  final String videoId;

  EthicalValueModel({
    required this.name,
    required this.level,
    required this.videoId,
  });

  static final Map<String, String> videoLinks = {
    "الصدق": "LYAlD6QSKM0",
    "الأمانة": "ttJD_mJ2B18",
    "التعاون": "ttJD_mJ2B18",
    "الإحسان": "t9Noxyf56Nw",
    "الشجاعة": "KIxhA-XMd9s",
    "التواضع": "9iiLOfmnkjI"
  };

  factory EthicalValueModel.fromName(String name, int level) {
    return EthicalValueModel(
      name: name,
      level: level,
      videoId: videoLinks[name] ?? "",
    );
  }
}