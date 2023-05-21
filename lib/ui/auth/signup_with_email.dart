import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_app/models/user_model.dart';
import 'package:photo_app/services/auth.service.dart';
import 'package:photo_app/services/helper.dart';
import 'package:photo_app/services/shared_preferences.dart';
import 'package:photo_app/ui/auth/auth_login_screen.dart';
import 'package:photo_app/ui/home/home.dart';

class SignUpWithEmail extends StatefulWidget {
  @override
  _SignUpWithEmailState createState() => _SignUpWithEmailState();
}

class _SignUpWithEmailState extends State<SignUpWithEmail> {
  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController usernameController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');
  AuthService _authService = AuthService();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  SharedPreferencesService _sharedPreferencesService = SharedPreferencesService();

  bool validEmail = false;
  bool validUsername = false;
  bool validPassword = false;
  int passwordLength = 0;
  bool togglePassword = false;
  bool userEmailDoesNotExist = false;
  bool userPasswordDoesNotExist = false;
  bool usernameExist = false;
  bool userEmailExist = false;
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
                    'Register new account',
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
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      controller: emailController,
                      inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))],
                      onChanged: (text) {
                        bool isEmailValid = validateEmail(text);
                        setState(() {
                          validEmail = isEmailValid;
                        });

                        if (text.length == 0) {
                          setState(() {
                            validEmail = false;
                          });
                        }
                      },
                      style: TextStyle(fontSize: 17),
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
                        suffixIcon: !validEmail
                            ? null
                            : Icon(
                                Icons.check,
                                color: Colors.blue,
                                size: 24,
                              ),
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(fontSize: 17),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: userEmailExist,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.0, right: 24.0, left: 24.0),
                        child: Text(
                          'Email is already in use or is invalid',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      controller: usernameController,
                      onChanged: (text) {
                        setState(() {
                          validUsername = text.length >= 5 && text.length >= 10;
                        });
                      },
                      style: TextStyle(fontSize: 17),
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
                        suffixIcon: !validUsername
                            ? null
                            : Icon(
                                Icons.check,
                                color: Colors.blue,
                                size: 24,
                              ),
                        hintText: 'Enter your username',
                        hintStyle: TextStyle(fontSize: 17),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: usernameExist,
                      child: Text(
                        'Username already exist',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      obscureText: !togglePassword,
                      controller: passwordController,
                      onChanged: (text) {
                        setState(() {
                          passwordLength = text.length;
                          validPassword = false;
                        });
                        var isValidPassword = validatePassword(text);
                        if (isValidPassword == true)
                          setState(() {
                            validPassword = true;
                          });
                        if (text.length == 0)
                          setState(() {
                            validPassword = false;
                          });
                        if (text.length < 8)
                          setState(() {
                            validPassword = false;
                          });
                      },
                      onTap: () async {},
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontSize: 17),
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 0,
                          bottom: 0,
                        ),
                        suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          icon: Icon(
                            !togglePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                            color: Colors.grey,
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              togglePassword = !togglePassword;
                            });
                          },
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(fontSize: 17),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password must have',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: passwordLength < 8 ? Colors.grey : Colors.green,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '8 to 20 characters',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: validPassword ? Colors.green : Colors.grey,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Numbers, letters, and special characters',
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
              SizedBox(height: 24),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.grey.shade200,
                    backgroundColor: (!validEmail && !validPassword)
                        ? Colors.grey.shade200
                        : !isLoading
                            ? Colors.blue
                            : Colors.grey.shade200,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
                  ),
                  onPressed: validEmail && validPassword ? () => !isLoading ? createNewUser() : null : null,
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 21,
                              height: 21,
                              child: CircularProgressIndicator(color: Colors.blue),
                            ),
                          ],
                        )
                      : Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      push(context, AuthLoginScreen(), 'AuthLoginScreen', false);
                    },
                    child: Text(
                      'Sign In',
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

  Future<void> createNewUser() async {
    FocusScope.of(context).unfocus();
    try {
      setState(() {
        userEmailExist = false;
        isLoading = true;
      });

      await checkIfUserAndEmailExists();

      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      UserModel user = UserModel(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        username: capitalizeFirstLetter(usernameController.text.trim()),
        userId: result.user!.uid,
        profilePictureUrl: avatar(usernameController.text.trim()),
      );
      var createdUser = await _authService.createUser(user);
      await _sharedPreferencesService.setSharedPreferencesString('user', jsonEncode(createdUser));
      push(context, HomeScreen(), 'HomeScreen', false);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // showSnackBar(context, 'errorOccurred'.tr(), Colors.red);
    }
  }

  Future checkIfUserAndEmailExists() async {
    bool usernameExist = await _authService.checkIfUsernameExist(usernameController.text.trim());
    if (usernameExist) {
      setState(() {
        usernameExist = true;
        isLoading = false;
      });
      return;
    }
    bool emailExist = await _authService.checkIfEmailExist(emailController.text.trim());
    if (emailExist) {
      setState(() {
        userEmailExist = true;
        isLoading = false;
      });
      return;
    }
  }

  googleAuth(BuildContext context) {}
}
