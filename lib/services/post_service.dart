import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_app/constants.dart';
import 'package:photo_app/models/post_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:photo_app/models/user_model.dart';
import 'package:photo_app/services/helper.dart';
import 'package:photo_app/services/user.service.dart';

class PostService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Reference storage = FirebaseStorage.instance.ref();
  String storageUrl = 'photoapp';
  UserService _userService = UserService();
  StreamController<List<PostModel>> _postsStream = StreamController.broadcast();

  Stream<List<PostModel>> getPostsStream() async* {
    try {
      List<PostModel> postData = [];
      _postsStream = StreamController();
      Stream<QuerySnapshot> result = firestore.collection(POSTS).orderBy('createdAt', descending: true).snapshots();
      result.listen((QuerySnapshot querySnapshot) async {
        postData.clear();
        await Future.forEach(querySnapshot.docs, (DocumentSnapshot post) async {
          PostModel postModel = PostModel.fromJson(post.data() as Map<String, dynamic>);
          UserModel? author = await _userService.getCurrentUser(postModel.authorId);
          postModel.author = author;
          if (!_postsStream.isClosed) {
            postData.add(postModel);
          }
        });
        _postsStream.sink.add(postData);
      });
      yield* _postsStream.stream;
    } catch (e) {
      throw [];
    }
  }

  Future createPost(PostModel post, File? file) async {
    try {
      PostModel createdPost = await uploadImageAndUpdateImageUrl(post, file);
      await firestore.collection(POSTS).doc(createdPost.postId).set(createdPost.toJson());
    } catch (e) {
      throw e;
    }
  }

  Future updatePost(PostModel post, File? file) async {
    try {
      PostModel updatedPost = await uploadImageAndUpdateImageUrl(post, file);
      await firestore.collection(POSTS).doc(updatedPost.postId).update(updatedPost.toJson());
    } catch (e) {
      throw e;
    }
  }

  Future<PostModel> uploadImageAndUpdateImageUrl(PostModel post, File? file) async {
    if (file != null) {
      String imageUrl = await uploadImage(file);
      post.imageUrl = imageUrl;
      String backgroundImageColor = '';
      if (post.imageUrl.isNotEmpty) {
        Color bgColor = await getImagePalette(networkImage(post.imageUrl).image);
        backgroundImageColor = '#${bgColor.value.toRadixString(16).substring(2, 8)}';
        post.bgImageColor = backgroundImageColor;
      }
    }
    return post;
  }

  Future<String> uploadImage(File file) async {
    try {
      String extension = path.extension(file.path);
      String uniqueId = getRandomString(28);
      Reference upload = storage.child("$storageUrl/images/${uniqueId}.${extension}");
      UploadTask uploadTask = upload.putFile(file);
      var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
      return downloadUrl.toString();
    } catch (e) {
      return 'Error uploading image.';
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await firestore.collection(POSTS).doc(postId).delete();
    } catch (e) {
      throw e;
    }
  }

  void disposePostStream() {
    _postsStream.close();
  }
}
