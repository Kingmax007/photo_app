import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_app/models/post_model.dart';
import 'package:photo_app/models/user_model.dart';
import 'package:photo_app/services/helper.dart';
import 'package:photo_app/services/post_service.dart';
import 'package:photo_app/ui/posts/edit_post.dart';

class PostHeader extends StatelessWidget {
  final UserModel user;
  final PostModel postModel;

  PostHeader({
    required this.postModel,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    PostService _postService = PostService();
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Container(
              child: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue,
                child: CircleAvatar(
                  radius: 20.0,
                  backgroundImage: Image.network(postModel.author!.profilePictureUrl).image,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {},
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.60,
                          child: RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: postModel.author!.username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: user.userId == postModel.authorId
                            ? () async {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.white,
                                  builder: (context1) {
                                    return postFileSelectSheet(
                                      context,
                                      showEditMedia: true,
                                      showDeleteMedia: true,
                                      onEditMedia: () {
                                        Navigator.pop(context);
                                        push(
                                          context,
                                          EditPostScreen(postModel: postModel, user: user),
                                          'EditPostScreen',
                                          true,
                                        );
                                      },
                                      onDeleteMedia: () async {
                                        Navigator.pop(context);
                                        try {
                                          var proceed = await showAlertDialog(
                                            context,
                                            'Are you sure you want to delete?',
                                            'Delete',
                                            'Delete',
                                          );
                                          if (proceed) {
                                            await _postService.deletePost(postModel.postId);
                                          }
                                        } catch (e) {
                                          showSnackBar(
                                            context,
                                            'Error deleting post. Please try again later.',
                                            Colors.red,
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                              }
                            : null,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Icon(
                          Icons.more_horiz,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Icon(
                              FontAwesomeIcons.clock,
                              color: Colors.grey,
                              size: 14,
                            ),
                          ),
                          Text(
                            timeFromDate(postModel.createdAt),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
