class SignUpModel {
  final String name;
  final String email;
  final String password;

  SignUpModel({required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    //'password': password,
    };
  }
}
