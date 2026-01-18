class User {
  String? id;
  String username;
  String password;
  String email;
  String contactNo;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.contactNo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'contactNo': contactNo,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? map['_id']?.toString(), // Handle both if transitioning or just id
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      email: map['email'] ?? '',
      contactNo: map['contactNo'] ?? '',
    );
  }
}
