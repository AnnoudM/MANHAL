class Child {
  String name;
  String gender;
  int age;
  String? photoUrl; // خاصية جديدة لحفظ مسار الصورة

  Child({
    required this.name,
    required this.gender,
    required this.age,
    this.photoUrl,
  });

  // لتحويل الكائن إلى خريطة لتخزينها في Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'photoUrl': photoUrl,  // إضافة الصورة إلى الخريطة
    };
  }

  // لتحويل البيانات من Firestore إلى كائن Child
  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      photoUrl: map['photoUrl'],  // استرجاع الصورة من البيانات
    );
  }
}
