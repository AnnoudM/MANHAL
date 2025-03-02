class ContentModel {
  final String id;
  final String name;
  final bool isLocked;
  final String? subCategory;
  final List<String> examples;

  ContentModel({
    required this.id,
    required this.name,
    required this.isLocked,
    this.subCategory,
    this.examples = const [],
  });

  factory ContentModel.fromMap(Map<String, dynamic>? data, String id,
      {String? subCategory}) {
    if (data == null) {
      return ContentModel(
        id: id,
        name: "غير معروف",
        isLocked: false,
        subCategory: subCategory,
        examples: [],
      );
    }

    return ContentModel(
      id: id,
      name: data["name"] ?? id, // 🔥 الاسم هو إما "name" أو "id" كبديل
      isLocked: data["isLocked"] ?? false,
      subCategory: subCategory,
      examples: data["examples"] is List
          ? List<String>.from(data["examples"] as List<dynamic>)
          : [],
    );
  }

  ContentModel copyWith({bool? isLocked}) {
    return ContentModel(
      id: id,
      name: name,
      isLocked: isLocked ?? this.isLocked,
      subCategory: subCategory,
      examples: examples,
    );
  }
}
