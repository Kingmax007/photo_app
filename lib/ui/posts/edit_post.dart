import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_app/models/post_model.dart';
import 'package:photo_app/models/user_model.dart';
import 'package:photo_app/services/helper.dart';
import 'package:photo_app/services/post_service.dart';
import 'package:photo_app/ui/widgets/loading_overlay.dart';

class EditPostScreen extends StatefulWidget {
  final UserModel user;
  final PostModel postModel;
  const EditPostScreen({super.key, required this.user, required this.postModel});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  FocusNode _focusNode = FocusNode();
  TextEditingController _postController = TextEditingController();
  PostService _postService = PostService();
  File imageFile = File('');
  String imageString = '';
  bool hasPhotos = false;
  String _enteredTitleText = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _postController.text = widget.postModel.post;
          _enteredTitleText = widget.postModel.post;
          _postController.selection = TextSelection.fromPosition(
            TextPosition(offset: _postController.text.length),
          );
          if (widget.postModel.imageUrl.isNotEmpty) {
            hasPhotos = true;
            imageString = widget.postModel.imageUrl;
          }
        });
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
          'Edit Post',
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
            onTap: _postController.text.isNotEmpty || hasPhotos ? () => editPost() : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Center(
                child: Text(
                  'Save',
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
                    imageString = '';
                  });
                },
              );
            },
          );
        },
        child: imageString.isEmpty
            ? Image(
                fit: BoxFit.cover,
                image: Image.file(imageFile).image,
              )
            : networkImage(imageString),
      );
    });
  }

  Future<void> editPost() async {
    FocusScope.of(context).unfocus();
    LoadingOverlay.of(context).show();
    try {
      PostModel updatedPost = PostModel(
        authorId: widget.postModel.authorId,
        post: _postController.text.trim(),
        imageUrl: imageFile.path.isEmpty && imageString.isNotEmpty ? imageString : '',
        createdAt: widget.postModel.createdAt,
        bgImageColor: widget.postModel.bgImageColor,
        postId: widget.postModel.postId,
      );
      String? errorMessage = await _postService.updatePost(updatedPost, imageFile.path.isNotEmpty ? imageFile : null);
      LoadingOverlay.of(context).hide();
      if (errorMessage == null) {
        _postController.clear();
        Navigator.pop(context);
      }
    } catch (e) {
      LoadingOverlay.of(context).hide();
      showSnackBar(context, 'Error updating post. Please try again later.', Colors.red);
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
        imageString = '';
      });
    } catch (e) {
      setState(() {
        hasPhotos = false;
      });
      showSnackBar(context, 'Cannot select image.', Colors.red);
    }
  }
}
