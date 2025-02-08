class Child {
  String name;
  String gender;
  int age;

  Child({required this.name, required this.gender, required this.age});

  // لتحويل الكائن إلى خريطة لتخزينها في Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
    };
  }

  // لتحويل البيانات من Firestore إلى كائن Child
  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
    );
  }
}
