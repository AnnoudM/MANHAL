class PersonalInfoModel {
  String name;
  String email;

  PersonalInfoModel({required this.name, required this.email});

  // لتحويل البيانات إلى JSON لحفظها في Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
    };
  }

  // لإنشاء كائن من البيانات المسترجعة من Firebase
  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonalInfoModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
