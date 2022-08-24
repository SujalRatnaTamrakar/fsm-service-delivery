import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/constants/constants.dart';
import 'package:my_app/models/Supabase_helper.dart';
import 'package:my_app/screens/containment_screen.dart';
import 'package:my_app/screens/emptyingServiceScreen.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/screens/map_screen.dart';
import 'package:my_app/screens/upload_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static final id = 'HomeScreen';

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _email;

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit the application?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonStr = prefs.getString(PERSIST_SESSION_KEY);
    final response = await supabase.auth.recoverSession(jsonStr);
    prefs.setString(PERSIST_SESSION_KEY, response.data.persistSessionString);
    setState(() {
      _email = response.data.user.email;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.all_inclusive_outlined),
          title: const Text('Home'),
          actions: <Widget>[],
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromRGBO(101, 157, 82, 1),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.person,
                                size: 70,
                                color: Color.fromRGBO(101, 157, 82, 1),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: Text(
                                  'E-mail :\n$_email',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color.fromRGBO(101, 157, 82, 1),
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.clip,
                                  textAlign: TextAlign.left,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: <Widget>[
                  if ((_email == "user1@imisapp.com") ||
                      (_email == "admin@imisapp.com"))
                    buildCardWithIcon(
                      Icons.my_library_add_outlined,
                      context,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ContainmentScreen();
                            },
                          ),
                        );
                      },
                      "Containment Assessment",
                    ),
                  if (_email == "user2@imisapp.com" ||
                      _email == "admin@imisapp.com")
                    buildCardWithIcon(
                      Icons.hourglass_empty,
                      context,
                      () {
                        Navigator.of(context).push(EmptyingServiceRoute());
                      },
                      "Emptying Service",
                    ),
                  if (_email == "user3@imisapp.com" ||
                      _email == "admin@imisapp.com")
                    buildCardWithIcon(
                      Icons.map,
                      context,
                      () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MapScreen();
                        }));
                      },
                      "BCICS",
                    ),
                  if (_email == "user3@imisapp.com" ||
                      _email == "admin@imisapp.com")
                    buildCardWithIcon(
                      Icons.file_upload,
                      context,
                      () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return UploadScreen();
                        }));
                      },
                      "Upload",
                    ),
                  buildCardWithIcon(
                    Icons.logout,
                    context,
                    () async {
                      final response = await supabase.auth.signOut();

                      if (response.error != null) {
                        print('Error: ${response.error?.message}');
                      } else {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.remove(PERSIST_SESSION_KEY);
                        print('logged out !');
                        Navigator.of(context)
                            .pushReplacementNamed(LoginScreen.id);
                      }
                    },
                    "Logout",
                  ),
                  // buildCardWithIcon(
                  //   Icons.logout,
                  //   context,
                  //   () async {
                  //     final res1 = await supabase.auth
                  //         .signUp('user1@imisapp.com', 'test123');
                  //     final res2 = await supabase.auth
                  //         .signUp('user2@imisapp.com', 'test123');
                  //     final res3 = await supabase.auth
                  //         .signUp('user3@imisapp.com', 'test123');
                  //   },
                  //   "Make user",
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Padding buildCardWithIcon(
    IconData icon, context, VoidCallback onTap, String pageName) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: InkWell(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 70,
                color: Color.fromRGBO(101, 157, 82, 1),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                pageName,
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(101, 157, 82, 1),
                ),
                softWrap: true,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    ),
  );
}

class EmptyingServiceRoute extends CupertinoPageRoute {
  EmptyingServiceRoute()
      : super(builder: (BuildContext context) => EmptyingServiceScreen());

  // OPTIONAL IF YOU WISH TO HAVE SOME EXTRA ANIMATION WHILE ROUTING
  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(opacity: animation, child: EmptyingServiceScreen());
  }

  // @override
  // Widget buildTransitions(BuildContext context, Animation<double> animation,
  //     Animation<double> secondaryAnimation, Widget child) {
  //   //return child;
  //   // Fades between routes. (If you don't want any animation,
  //   // just return child.)
  //   return FadeTransition(opacity: animation, child: child);
  // }
}
