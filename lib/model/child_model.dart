class Child {
  String name;
  String gender;
  int age;

  Child({required this.name, required this.gender, required this.age});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
    };
  }
}