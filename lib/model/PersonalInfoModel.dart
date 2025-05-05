class PersonalInfoModel {
  String name;
  String email;

  PersonalInfoModel({required this.name, required this.email});

  // Convert data to JSON for saving in Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
    };
  }

  // Create an instance from data retrieved from Firebase
  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonalInfoModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
