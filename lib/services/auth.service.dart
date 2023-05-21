import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_app/constants.dart';
import 'package:photo_app/models/user_model.dart';
import 'package:photo_app/services/user.service.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  UserService _userService = UserService();

  Future createUser(UserModel user) async {
    try {
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      }
    } catch (e) {
      return 'Could not signup user';
    }
  }

  Future loginWithEmailAndPassword(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await firestore.collection(USERS).doc(uid).get();
      UserModel? user;
      if (documentSnapshot.exists) {
        user = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
      }
      return user;
    } catch (e) {
      return 'Login failed';
    }
  }

  Future firebaseCreateNewUser(UserModel user) async {
    try {
      await firestore.collection(USERS).doc(user.userId).set(user.toJson());
      return null;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> checkIfEmailExist(String email) async {
    try {
      var userDocument = await FirebaseFirestore.instance.collection(USERS).where('email', isEqualTo: email).get();
      return userDocument.docs.length >= 1 ? true : false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIfUsernameExist(String username) async {
    try {
      var userDocument =
          await FirebaseFirestore.instance.collection(USERS).where('username', isEqualTo: username).get();
      return userDocument.docs.length >= 1 ? true : false;
    } catch (e) {
      return false;
    }
  }

  Future signInWithGoogle(GoogleSignInAccount? googleUser) async {
    try {
      if (googleUser != null) {
        GoogleSignInAuthentication googleSignInAuth = await googleUser.authentication;
        AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuth.accessToken,
          idToken: googleSignInAuth.idToken,
        );
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        UserModel? user = await _userService.getCurrentUserByEmail(userCredential.user!.email!);
        if (user is UserModel) {
          return user;
        } else {
          return userCredential;
        }
      }
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> signInWithFacebook(LoginResult fbResult) async {
    try {
      if (fbResult.status != LoginStatus.cancelled) {
        final AccessToken accessToken = fbResult.accessToken!;
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(
          FacebookAuthProvider.credential(accessToken.token),
        );
        UserModel? user = await _userService.getCurrentUserByEmail(userCredential.user!.email!);
        if (user is User) {
          return user;
        } else {
          return userCredential;
        }
      }
    } catch (e) {
      throw e;
    }
  }
}
