class ChildProfileModel {
  final String name;
  final String gender;
  final int age;
  String selectedImage; // Profile image

  ChildProfileModel({
    required this.name,
    required this.gender,
    required this.age,
    this.selectedImage = 'assets/images/default_avatar.jpg', // Default image
  });

  // Load data from Firestore
  factory ChildProfileModel.fromFirestore(Map<String, dynamic> data) {
    return ChildProfileModel(
      name: data['name'] ?? 'Unknown',
      gender: data['gender'] ?? 'Unspecified',
      age: data['age'] ?? 0,
      selectedImage: data['selectedImage'] ?? 'assets/images/girl.png',
    );
  }

  // Convert the model to a Map for saving in Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'selectedImage': selectedImage,
    };
  }
}
