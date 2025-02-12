class Child {
  String name;
  String gender;
  int age;
  String? photoUrl;
  String parentId; // لإضافة معرف الوالد

  Child({
    required this.name,
    required this.gender,
    required this.age,
    this.photoUrl,
    required this.parentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'photoUrl': photoUrl,
      'parentId': parentId,
    };
  }

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      photoUrl: map['photoUrl'],
      parentId: map['parentId'] ?? '',
    );
  }
}
