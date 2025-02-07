class ChildProfileModel {
  final String name;
  final String gender;
  final int age;

  ChildProfileModel({
    required this.name,
    required this.gender,
    required this.age,
  });

  // Factory لتحميل البيانات من Firebase
  factory ChildProfileModel.fromFirestore(Map<String, dynamic> data) {
    return ChildProfileModel(
      name: data['name'] ?? 'غير معروف',
      gender: data['gender'] ?? 'غير محدد',
      age: data['age'] ?? 0,
    );
  }
}