import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_app/models/post_model.dart';
import 'package:photo_app/models/user_model.dart';
import 'package:photo_app/services/helper.dart';
import 'package:photo_app/services/post_service.dart';
import 'package:photo_app/services/shared_preferences.dart';
import 'package:photo_app/ui/auth/auth_login_screen.dart';
import 'package:photo_app/ui/posts/create_post.dart';
import 'package:photo_app/ui/widgets/full_screen_image_viewer.dart';
import 'package:photo_app/ui/widgets/post_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SharedPreferencesService _sharedPreferencesService = SharedPreferencesService();
  PostService _postService = PostService();
  ScrollController _scrollController = ScrollController();
  UserModel user = UserModel();
  late Stream<List<PostModel>> _postsStream;

  @override
  void initState() {
    if (mounted) {
      _postsStream = _postService.getPostsStream();
      getSavedUser();
    }
    super.initState();
  }

  @override
  void dispose() {
    _postService.disposePostStream();
    super.dispose();
  }

  Future<void> getSavedUser() async {
    String item = await _sharedPreferencesService.getSharedPreferencesString('user');
    setState(() {
      user = UserModel(
        email: jsonDecode(item)['email'],
        username: jsonDecode(item)['username'],
        userId: jsonDecode(item)['userId'],
        profilePictureUrl: jsonDecode(item)['profilePictureUrl'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(
          'Photo App',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        elevation: 0.0,
        backgroundColor: Colors.white,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  push(context, CreatePostScreen(user: user), 'CreatePostScreen', false);
                },
                child: Container(
                  padding: EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                  child: Icon(
                    FontAwesomeIcons.squarePlus,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () async {
                  await logout(context);
                },
                child: Container(
                  padding: EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                  child: Icon(
                    FontAwesomeIcons.powerOff,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: Color(0xFFF1F2F6)),
          child: StreamBuilder<List<PostModel>>(
            stream: _postsStream,
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                return Center(
                  child: Container(
                    child: Text(
                      'No posts found',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  physics: ScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return _postWidget(snapshot.data![index]);
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _postWidget(PostModel postModel) {
    return Card(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey, width: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.only(top: 12, bottom: 10, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeader(postModel: postModel, user: user),
            Visibility(
              visible: postModel.post.isNotEmpty,
              child: Text(
                postModel.post.trim(),
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            postModel.imageUrl.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      push(
                        context,
                        FullScreenImageViewer(imageUrl: postModel.imageUrl),
                        'FullScreenImageViewer',
                        false,
                      );
                    },
                    child: Container(
                      color:
                          postModel.bgImageColor.isNotEmpty ? hexStringToColor(postModel.bgImageColor) : Colors.white,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(bottom: 10),
                      child: displayImage(
                        postModel.imageUrl,
                        MediaQuery.of(context).size.height * 0.5,
                        hasBgColor: postModel.bgImageColor.isNotEmpty,
                        bgColor:
                            postModel.bgImageColor.isNotEmpty ? hexStringToColor(postModel.bgImageColor) : Colors.white,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await _sharedPreferencesService.deleteSharedPreferencesItem('user');
    await FirebaseAuth.instance.signOut();
    push(context, AuthLoginScreen(), 'AuthLoginScreen', false);
  }
}
