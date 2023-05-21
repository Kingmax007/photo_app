import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:photo_app/models/user_model.dart';
import 'package:photo_app/services/helper.dart';
import 'package:photo_app/services/user.service.dart';
import 'package:photo_app/ui/auth/auth_login_screen.dart';
import 'package:photo_app/ui/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(const MyApp());
  }, (error, stackTrace) {});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");
  static final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo App',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      navigatorObservers: [
        routeObserver,
      ],
      home: OnBoarding(),
    );
  }
}

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State createState() {
    return OnBoardingState();
  }
}

class OnBoardingState extends State<OnBoarding> {
  UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigateToNavScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     body: Center(
        child: Container(

          child: Text(
            'PHOTO APP',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> navigateToNavScreen() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      UserModel? user = await _userService.getCurrentUser(firebaseUser.uid);
      if (user != null) {
        push(context, HomeScreen(), 'HomeScreen', false);
      } else {
        push(context, AuthLoginScreen(), 'AuthLoginScreen', false);
      }
    } else {
      push(context, AuthLoginScreen(), 'AuthLoginScreen', false);
    }
  }
}
