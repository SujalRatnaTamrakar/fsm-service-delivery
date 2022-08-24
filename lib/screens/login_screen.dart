import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:my_app/constants/constants.dart';
import 'package:my_app/models/Supabase_helper.dart';
import 'package:my_app/screens/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static final id = 'loginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _inAsynCall = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image(
          image: AssetImage("images/login_bg.PNG"),
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Color.fromRGBO(101, 157, 82, 0.8),
          body: ModalProgressHUD(
            inAsyncCall: _inAsynCall,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'logo',
                        child: Image(
                          image: AssetImage("images/logo.png"),
                          height: 150.0,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      FormBuilder(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(children: <Widget>[
                            FormBuilderTextField(
                              name: 'email',
                              keyboardType: TextInputType.emailAddress,
                              controller: _email,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.email(context),
                                FormBuilderValidators.required(context)
                              ]),
                              decoration: kLoginInputDecoration.copyWith(
                                prefixIcon: Icon(Icons.email),
                                labelText: 'E-mail',
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            FormBuilderTextField(
                              name: 'password',
                              controller: _password,
                              obscureText: true,
                              obscuringCharacter: '*',
                              validator:
                                  FormBuilderValidators.required(context),
                              decoration: kLoginInputDecoration.copyWith(
                                prefixIcon: Icon(Icons.password),
                                labelText: 'Password',
                              ),
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  _inAsynCall = true;
                                });
                                if (_formKey.currentState.validate()) {
                                  final response = await supabase.auth.signIn(
                                      email: _email.value.text,
                                      password: _password.value.text);
                                  setState(() {
                                    _inAsynCall = false;
                                  });

                                  if (response.error != null) {
                                    print('Error: ${response.error?.message}');
                                    showToast(
                                      'Error Logging in! \n Check if email and password are correct',
                                      context: context,
                                      animation: StyledToastAnimation.scale,
                                      reverseAnimation:
                                          StyledToastAnimation.fade,
                                      position: StyledToastPosition.center,
                                      animDuration: Duration(milliseconds: 50),
                                      duration: Duration(seconds: 1),
                                      curve: Curves.elasticOut,
                                      reverseCurve: Curves.linear,
                                    );
                                  } else {
                                    if (response.data == null) {
                                      CircularProgressIndicator();
                                    } else {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setString(PERSIST_SESSION_KEY,
                                          response.data.persistSessionString);
                                      Navigator.pushNamed(
                                          context, HomeScreen.id);
                                    }
                                  }
                                } else {
                                  showToast(
                                    'Error Logging in! \n Check if fields are correct!',
                                    context: context,
                                    animation: StyledToastAnimation.scale,
                                    reverseAnimation: StyledToastAnimation.fade,
                                    position: StyledToastPosition.center,
                                    animDuration: Duration(milliseconds: 50),
                                    duration: Duration(seconds: 1),
                                    curve: Curves.elasticOut,
                                    reverseCurve: Curves.linear,
                                  );
                                }
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
