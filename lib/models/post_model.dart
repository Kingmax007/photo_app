import 'package:photo_app/models/user_model.dart';

class PostModel {
  UserModel? author;
  String postId;
  String authorId;
  String post;
  String imageUrl;
  String bgImageColor;
  String createdAt;

  PostModel({
    author,
    this.postId = '',
    this.authorId = '',
    this.post = '',
    this.imageUrl = '',
    this.createdAt = '',
    this.bgImageColor = '',
  });

  factory PostModel.fromJson(Map<String, dynamic> parsedJson) {
    return new PostModel(
      author: parsedJson.containsKey('author') && parsedJson['author'] != null
          ? UserModel.fromJson(parsedJson['author'])
          : UserModel(),
      postId: parsedJson['postId'] ?? '',
      authorId: parsedJson['authorId'] ?? '',
      post: parsedJson['post'] ?? '',
      imageUrl: parsedJson['imageUrl'] ?? '',
      createdAt: parsedJson['createdAt'] ?? '',
      bgImageColor: parsedJson['bgImageColor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "author": this.author != null ? this.author!.toJson() : null,
      "postId": this.postId,
      "authorId": this.authorId,
      "post": this.post,
      "imageUrl": this.imageUrl,
      "createdAt": this.createdAt,
      "bgImageColor": this.bgImageColor,
    };
  }


}
