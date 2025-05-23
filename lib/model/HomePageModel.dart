class HomePageModel {
  final String userName;
  final String gender;
  final int age;
  final String photoUrl;

  HomePageModel({
    required this.userName,
    required this.gender,
    required this.age,
    required this.photoUrl,
  });
  // Based on the selected child, create model from firestosre
  factory HomePageModel.fromFirebase(Map<String, dynamic> data) {
    return HomePageModel(
      userName: data['name'] ?? 'غير معروف',
      gender: data['gender'] ?? 'غير محدد',
      age: data['age'] ?? 0,
      photoUrl: data['photoUrl'] ?? 'assets/images/default_avatar.jpg',
    );
  }
}