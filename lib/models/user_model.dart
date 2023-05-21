import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String email;
  String username;
  String password;
  String userId;
  String profilePictureUrl;
  Timestamp createdAt;

  UserModel({
    this.email = '',
    this.username = '',
    this.password = '',
    this.userId = '',
    this.profilePictureUrl = '',
    createdAt,
  }) : this.createdAt = createdAt ?? Timestamp.now();

  factory UserModel.fromJson(Map<String, dynamic> parsedJson) {
    return new UserModel(
      email: parsedJson['email'] ?? '',
      username: parsedJson['username'] ?? '',
      password: parsedJson['password'] ?? '',
      userId: parsedJson['userId'] ?? '',
      profilePictureUrl: parsedJson['profilePictureUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': this.email,
      'username': this.username,
      // 'password': this.password, // password is not needed to be saved. Firebase auth will handle users password
      'userId': this.userId,
      'profilePictureUrl': this.profilePictureUrl,
    };
  }
}
