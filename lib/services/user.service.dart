import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_app/constants.dart';
import 'package:photo_app/models/user_model.dart';

class UserService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserModel?> getCurrentUser(String uid) async {
    try {
      DocumentSnapshot userDocument = await firestore.collection(USERS).doc(uid).get();
      if (userDocument.data() != null && userDocument.exists) {
        UserModel user = UserModel.fromJson(userDocument.data() as Map<String, dynamic>);
        return user;
      } else {
        return null;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<UserModel?> getCurrentUserByEmail(String email) async {
    try {
      List<UserModel> _userList = [];
      QuerySnapshot result = await firestore.collection(USERS).where('email', isEqualTo: email).get();
      await Future.forEach(result.docs, (DocumentSnapshot user) {
        UserModel userData = UserModel.fromJson(user.data() as Map<String, dynamic>);
        _userList.add(userData);
      });
      return _userList.isNotEmpty ? _userList[0] : null;
    } catch (e) {
      throw e;
    }
  }
}
