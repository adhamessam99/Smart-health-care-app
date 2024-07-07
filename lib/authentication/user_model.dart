class UserModel {
  final String? id;
  final String? username;
  final String? email;
  final String? phoneNo;
  final String? password;

  UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.username,
    required this.phoneNo,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? phoneNo,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "email": email,
      "phoneNo": phoneNo,
      "password": password,
    };
  }
}
