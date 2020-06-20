import 'dart:convert';
import 'package:agent_app/globals.dart' as globals;
import 'package:agent_app/agent_datamodels/agent.dart';
import 'package:agent_app/agent_views/welcome_agent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

/// Creates [LoginViewState] object.
class LoginView extends StatefulWidget {
  @override
  LoginViewState createState() => LoginViewState();
}

/// Creates the widgets that are visible at the running state of

/// login view interface.[alert_message] are printing on app screen when
/// agent cannot be authenticated.
class LoginViewState extends State<LoginView> {
  String alert_message = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Sign In",
        home: Scaffold(
          body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: <Widget>[
                  Image.asset(
                    "assets/agent_beginning_images/GPay_logo_rectangle.png",
                    height: 40,
                  ),
                  Text(
                    "Welcome to Google Pay Agent",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 9),

                    child: Text("Together let's make money simple",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15)),
                  ),
                  Image.asset(
                    "assets/agent_beginning_images/handshake.gif",
                    width: 350,
                    height: 350,
                  ),
                  OutlineButton(
                    child: Image.asset(
                      "assets/agent_beginning_images/sign_in_with_google.png",
                    ),
                    onPressed: _login,

                  ),
                  Text(
                    alert_message,
                    style: TextStyle(fontSize: 15, color: Colors.red),
                  ),
                ]),
          ),
        ));
  }

  /// Calls signIn function of Google Sign in plugin.
  /// Navigates to [WelcomeAgent] interface if signed in account is authenticated
  /// by firebase authentication otherwise prints error on console and stays

  /// on the [LoginViewState] interface. Sets [alert_message] in case of a failed
  /// authentication.
  _login() async {
    try {
      await (globals.googleSignIn).signIn();
      String email = globals.googleSignIn.currentUser.email;
      await checkRegisteredinDB(email);
    } catch (err) {
      print(err);
    }
  }

  Future<Agent> checkRegisteredinDB(String email) async {
    final http.Response response = await http.post(
      'https://fos-tracker-278709.an.r.appspot.com/get_agent',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "email": email,
      }),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = jsonDecode(response.body);
      globals.agent = Agent.fromJson(jsonMap);
      if (globals.agent.AgentEmail != "") {
        setState(() {
          alert_message = "";
        });
        globals.merchantsVerifiedbyAgent = await getMerchantsVerified();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomeAgent(),
            ));
      } else {
        setState(() {
          alert_message = "You are not a registered agent";
          globals.googleSignIn.signOut();
        });
      }
    } else {
      setState(() {
        alert_message = "Error: Failed to reach server";
        globals.googleSignIn.signOut();
      });
    }
  }
}

/// Fetches the number of merchants verified by the agent signed in [agent]
/// using google spanner APIs.
Future<int> getMerchantsVerified() async {
  String email = globals.googleSignIn.currentUser.email;
  int num = 0;
  final http.Response response = await http.post(
    'https://fos-tracker-278709.an.r.appspot.com/number_of_merchants_verified',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      "email": email,
    }),
  );
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    num = jsonMap["number_of_merchants"];
    return num;
  } else {
    return 0;
  }
}