import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/constants/constants.dart';
import 'package:my_app/models/Supabase_helper.dart';
import 'package:my_app/screens/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  static final id = 'SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _duration = new Duration(seconds: 1);
  void showSignIn() {
    new Timer(_duration, () {
      Navigator.of(context).pushReplacementNamed(LoginScreen.id);
    });
  }

  void _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    bool exist = prefs.containsKey(PERSIST_SESSION_KEY);
    if (!exist) {
      return showSignIn();
    }

    String jsonStr = prefs.getString(PERSIST_SESSION_KEY);
    final response = await supabase.auth.recoverSession(jsonStr);
    if (response.error != null) {
      prefs.remove(PERSIST_SESSION_KEY);
      return showSignIn();
    }
    prefs.setString(PERSIST_SESSION_KEY, response.data.persistSessionString);
    new Timer(_duration, () {
      Navigator.of(context).pushReplacementNamed(HomeScreen.id);
    });
  }

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Image(
        image: AssetImage("images/login_bg.PNG"),
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
      Scaffold(
        backgroundColor: Color.fromRGBO(101, 157, 82, 0.8),
        body: Center(
          child: Hero(
            tag: 'logo',
            child: Image(
              image: AssetImage("images/logo.png"),
              height: 200.0,
            ),
          ),
        ),
      ),
    ]);
  }
}
