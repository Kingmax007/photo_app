import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_app/models/user_model.dart';
import 'package:photo_app/services/auth.service.dart';
import 'package:photo_app/services/helper.dart';
import 'package:photo_app/services/shared_preferences.dart';
import 'package:photo_app/ui/auth/auth_signup_screen.dart';
import 'package:photo_app/ui/auth/login_with_email.dart';
import 'package:photo_app/ui/home/home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthLoginScreen extends StatefulWidget {
  @override
  _AuthLoginScreenState createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends State<AuthLoginScreen> {
  AuthService _authService = AuthService();
  SharedPreferencesService _sharedPreferencesService = SharedPreferencesService();


  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 0),
          child: Column(
            children: [
              Column(
                children: [
                  Text(
                    'Log in to Photo App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              SizedBox(height: 48),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildCircularButton(
                      'Email/Password',
                      Icons.email_outlined,
                      Colors.blue,
                      () => push(context, LoginWithEmail(), 'LoginWithEmail', false),
                    ),
                    SizedBox(height: 10),
                    buildCircularButton(
                      'Google',
                      FontAwesomeIcons.google,
                      Colors.red,
                      () => googleAuth(context),
                    ),
                    SizedBox(height: 10),
                    buildCircularButton(
                      'Facebook',
                      FontAwesomeIcons.facebook,
                      Colors.blue,
                      () => facebookAuth(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      push(context, AuthSignUpScreen(), 'AuthSignUpScreen', false);
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCircularButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        width: MediaQuery.of(context).size.width * 0.8,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Icon(
              icon,
              color: color,
              size: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    // fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }


  Future<void> googleAuth(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      dynamic result = await _authService.signInWithGoogle(googleUser);
      if (result != null && result is UserModel) {
        push(context, HomeScreen(), 'HomeScreen', false);
      } else {
        UserModel user = UserModel(
          email: result.user?.email,
          password: '',
          username: capitalizeFirstLetter('${result.user?.displayName}'),
          userId: result.user?.uid,
          profilePictureUrl: result.user?.photoURL!,
        );
        var createdUser = await _authService.createUser(user);
        await _sharedPreferencesService.setSharedPreferencesString('user', jsonEncode(createdUser));
        push(context, HomeScreen(), 'HomeScreen', false);
      }
    } catch (e) {
      showSnackBar(context, 'Error authenticating. Please try again later.', Colors.red);
    }
  }

  Future<void> facebookAuth(BuildContext context) async {
    try {
      final LoginResult fbResult = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );
      var userData = await FacebookAuth.instance.getUserData();
      dynamic result = await _authService.signInWithFacebook(fbResult);
      if (result != null && result is UserModel) {
        push(context, HomeScreen(), 'HomeScreen', false);
      } else {
        UserModel user = UserModel(
          email: result.user?.email,
          password: '',
          username: capitalizeFirstLetter('${result.user?.displayName}'),
          userId: result.user?.uid,
          profilePictureUrl: userData['picture']['data']['url'],
        );
        var createdUser = await _authService.createUser(user);
        await _sharedPreferencesService.setSharedPreferencesString('user', jsonEncode(createdUser));
        push(context, HomeScreen(), 'HomeScreen', false);
      }
    } catch (e) {
      showSnackBar(context, 'Error authenticating. Please try again later.', Colors.red);
    }
  }
}
