//import 'dart:developer';

import 'package:flutter/material.dart';
import 'sections/login/login.dart';
import 'network/socket.dart';
import 'package:logger/logger.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';


final log = Logger();

void main() => runApp(App());

class App extends StatelessWidget {
  // root

  App() {
    TransportumSocket().init();
  }

  @override
  Widget build(BuildContext context) {
    log.i("start app...");
    

    return MaterialApp(
        title: 'Транспортум',
        theme: ThemeData(
            primarySwatch: Colors.green, primaryColorLight: Color(0xFF21ba00)),
        home: AnimatedSplashScreen(
          nextScreen: LoginPage(),
          backgroundColor: Color(0xFF0c5600),
          splash: Image.asset("assets/logo-offline.png"),
          splashTransition: SplashTransition.scaleTransition,
          splashIconSize: 150,
          duration: 100,
          pageTransitionType: PageTransitionType.fade,
        ));
  }
}
