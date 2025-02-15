class Child {
  String id;       // معرف الطفل في Firestore
  String name;
  String gender;
  int age;
  String? photoUrl;
  String parentId; // معرف الوالد

  Child({
    required this.id, 
    required this.name,
    required this.gender,
    required this.age,
    this.photoUrl,
    required this.parentId,
  });

  // تحويل البيانات إلى Map عند تخزينها في Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'photoUrl': photoUrl,
      'parentId': parentId,
    };
  }

  // استرجاع البيانات من Firestore وتحويلها إلى Model
  factory Child.fromMap(String id, Map<String, dynamic> map) {
    return Child(
      id: id, // تخزين ID الوثيقة
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      photoUrl: map['photoUrl'],
      parentId: map['parentId'] ?? '',
    );
  }

  // دالة copyWith لتعديل بعض القيم دون إنشاء كائن جديد بالكامل
  Child copyWith({
    String? id,
    String? name,
    String? gender,
    int? age,
    String? photoUrl,
    String? parentId,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      parentId: parentId ?? this.parentId,
    );
  }

  
}
