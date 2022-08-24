import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/HomeScreen.dart';
import 'package:my_app/screens/containment_screen.dart';
import 'package:my_app/screens/emptyingServiceScreen.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:flutter/services.dart';
import 'package:my_app/screens/map_screen.dart';
import 'package:my_app/screens/splash_screen.dart';
import 'package:my_app/screens/upload_screen.dart';

void main() {
  //Preventing screen rotation
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  //Running app
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Roboto'),
      initialRoute: SplashScreen.id,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        EmptyingServiceScreen.id: (context) => EmptyingServiceScreen(),
        MapScreen.id: (context) => MapScreen(),
        SplashScreen.id: (context) => SplashScreen(),
        ContainmentScreen.id: (context) => ContainmentScreen(),
        UploadScreen.id: (context) => UploadScreen()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
