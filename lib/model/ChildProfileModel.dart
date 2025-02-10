class ChildProfileModel {
  final String name;
  final String gender;
  final int age;
  String selectedImage; // صورة البروفايل

  ChildProfileModel({
    required this.name,
    required this.gender,
    required this.age,
    this.selectedImage = 'assets/images/default_avatar.jpg', // صورة افتراضية
  });

  // تحميل البيانات من Firestore
  factory ChildProfileModel.fromFirestore(Map<String, dynamic> data) {
    return ChildProfileModel(
      name: data['name'] ?? 'غير معروف',
      gender: data['gender'] ?? 'غير محدد',
      age: data['age'] ?? 0,
      selectedImage: data['selectedImage'] ?? 'assets/images/girl.png',
    );
  }

  // تحويل النموذج إلى JSON لحفظه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'selectedImage': selectedImage,
    };
  }
}