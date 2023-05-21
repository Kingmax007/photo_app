import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_app/models/user_model.dart';
import 'package:photo_app/services/auth.service.dart';
import 'package:photo_app/services/helper.dart';
import 'package:photo_app/services/shared_preferences.dart';
import 'package:photo_app/ui/auth/auth_signup_screen.dart';
import 'package:photo_app/ui/home/home.dart';

class LoginWithEmail extends StatefulWidget {
  @override
  _LoginWithEmailState createState() => _LoginWithEmailState();
}

class _LoginWithEmailState extends State<LoginWithEmail> {
  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AuthService _authService = AuthService();
  SharedPreferencesService _sharedPreferencesService = SharedPreferencesService();

  bool validEmail = false;
  bool validPassword = false;
  int passwordLength = 0;
  bool togglePassword = false;
  bool userEmailDoesNotExist = false;
  bool userPasswordDoesNotExist = false;
  bool isLoading = false;

  @override
  void dispose() {
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
                    'Login to your account',
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
                        if (isEmailValid) {
                          setState(() {
                            validEmail = true;
                          });
                        } else {
                          setState(() {
                            validEmail = false;
                          });
                        }

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
                      visible: userEmailDoesNotExist,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.0, right: 24.0, left: 24.0),
                        child: Text(
                          'Email is invalid',
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
                      obscureText: !togglePassword,
                      controller: passwordController,
                      onChanged: (text) {
                        setState(() {
                          passwordLength = text.length;
                          validPassword = false;
                        });
                        var isValidPassword = validatePassword(text);
                        if (isValidPassword == true) {
                          setState(() {
                            validPassword = true;
                          });
                        }
                        if (text.length == 0) {
                          setState(() {
                            validPassword = false;
                          });
                        }
                        if (text.length < 8) {
                          setState(() {
                            validPassword = false;
                          });
                        }
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
                    Visibility(
                      visible: userPasswordDoesNotExist,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.0, right: 24.0, left: 24.0),
                        child: Text(
                          'Password is invalid',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
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
                  onPressed: validEmail && validPassword ? () => !isLoading ? checkIfEmailExist() : null : null,
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
                          'Sign In',
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
                  Text("Don't have an account? ", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  GestureDetector(
                    onTap: () {
                      push(context, AuthSignUpScreen(), 'AuthSignUpScreen', false);
                    },
                    child: Text('Sign Up', style: TextStyle(color: Colors.blue, fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkIfEmailExist() async {
    FocusScope.of(context).unfocus();
    setState(() {
      userEmailDoesNotExist = false;
      isLoading = true;
    });
    bool emailExist = await _authService.checkIfEmailExist(emailController.text.trim());
    if (emailExist) {
      _loginWithEmail();
    } else {
      setState(() {
        userEmailDoesNotExist = true;
        isLoading = false;
      });
    }
  }

  Future _loginWithEmail() async {
    setState(() {
      userPasswordDoesNotExist = false;
      isLoading = true;
    });
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      dynamic user = await _authService.loginWithEmailAndPassword(result.user?.uid ?? '');
      if (user is UserModel) {
        await _sharedPreferencesService.setSharedPreferencesString('user', jsonEncode(user));
        push(context, HomeScreen(), 'HomeScreen', false);
      } else if (user is String) {
        setState(() {
          isLoading = false;
        });
        print('$user');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // showSnackBar(context, 'authenticationError'.tr(), Colors.red);
      print(error);
    }
  }
}
