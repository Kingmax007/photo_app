import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_app/models/post_model.dart';
import 'package:photo_app/models/user_model.dart';
import 'package:photo_app/services/helper.dart';
import 'package:photo_app/services/post_service.dart';
import 'package:photo_app/ui/widgets/loading_overlay.dart';

class CreatePostScreen extends StatefulWidget {
  final UserModel user;
  const CreatePostScreen({super.key, required this.user});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  FocusNode _focusNode = FocusNode();
  TextEditingController _postController = TextEditingController();
  PostService _postService = PostService();
  File imageFile = File('');
  bool hasPhotos = false;
  String _enteredTitleText = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _postController.selection = TextSelection.fromPosition(
          TextPosition(offset: _postController.text.length),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          'New Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () async {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          GestureDetector(
            onTap: _postController.text.isNotEmpty || hasPhotos ? () => createPost() : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Center(
                child: Text(
                  'Send',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: _postController.text.isNotEmpty || hasPhotos ? Colors.white : Colors.white54,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 15, left: 10),
            child: Row(
              children: [
                SizedBox(width: 8.0),
                Container(
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundColor: Colors.blue,
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundImage: Image.network(widget.user.profilePictureUrl).image,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: RichText(
                        textAlign: TextAlign.left,
                        softWrap: true,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.user.username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.next,
                      minLines: 1,
                      maxLines: 10,
                      maxLength: 70,
                      controller: _postController,
                      focusNode: _focusNode,
                      onChanged: (text) {
                        setState(() {
                          _enteredTitleText = text;
                        });
                      },
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[900],
                      ),
                      decoration: new InputDecoration(
                        counterText: '',
                        filled: true,
                        isDense: true,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 17,
                        ),
                        hintText: "What's on your mind?",
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      builder: (context) {
                        return postFileSelectSheet(
                          context,
                          showChooseFromGallery: true,
                          onChooseFromGallery: _onPickImage,
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 25,
                    height: 25,
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        image: Image.network(
                          'https://res.cloudinary.com/ratingapp/image/upload/v1659466937/app_assets/image-icon.png',
                        ).image,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(bottom: 5, top: 20, right: 20),
            child: Text(
              '${70 - _enteredTitleText.length} characters remaining',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Visibility(
              visible: hasPhotos,
              child: GridView(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: MediaQuery.of(context).size.width,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  childAspectRatio: 1,
                ),
                children: displayFileImages(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> displayFileImages() {
    return List<Widget>.generate(1, (index) {
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            builder: (context) {
              return postFileSelectSheet(
                context,
                showDeleteMedia: true,
                onDeleteMedia: () {
                  Navigator.pop(context);
                  setState(() {
                    hasPhotos = !hasPhotos;
                    imageFile = File('');
                  });
                },
              );
            },
          );
        },
        child: Image(
          fit: BoxFit.cover,
          image: Image.file(imageFile).image,
        ),
      );
    });
  }

  Future<void> createPost() async {
    FocusScope.of(context).unfocus();
    try {
      LoadingOverlay.of(context).show();
      PostModel postModel = PostModel(
        authorId: widget.user.userId,
        post: _postController.text.trim(),
        imageUrl: '',
        createdAt: (new DateTime.now()).toString(),
        postId: getRandomString(28),
      );
      String? errorMessage = await _postService.createPost(postModel, imageFile.path.isNotEmpty ? imageFile : null);
      LoadingOverlay.of(context).hide();
      if (errorMessage == null) {
        _postController.clear();
        Navigator.pop(context);
      }
    } catch (e) {
      LoadingOverlay.of(context).hide();
      showSnackBar(context, 'Error creating post. Please try again later.', Colors.red);
    }
  }

  void _onPickImage() async {
    Navigator.pop(context);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        hasPhotos = true;
        imageFile = File(image!.path);
      });
    } catch (e) {
      setState(() {
        hasPhotos = false;
      });
      showSnackBar(context, 'Cannot select image.', Colors.red);
    }
  }
}
