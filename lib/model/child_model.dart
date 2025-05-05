class Child {
  String id;       // Child's document ID in Firestore
  String name;
  String gender;
  int age;
  String? photoUrl;
  String parentId; // Parent's document ID

  Child({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    this.photoUrl,
    required this.parentId,
  });

  // Convert object to Map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'photoUrl': photoUrl,
      'parentId': parentId,
    };
  }

  // Create a Child object from Firestore document
  factory Child.fromMap(String id, Map<String, dynamic> map) {
    return Child(
      id: id, // Assign document ID
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      photoUrl: map['photoUrl'],
      parentId: map['parentId'] ?? '',
    );
  }

  // Create a copy of the Child object with optional new values
  Child copyWith({
    String? id,
    String? name,
    String? gender,
    int? age,
    String? photoUrl,
    String? parentId,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      parentId: parentId ?? this.parentId,
    );
  }
}
