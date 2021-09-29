import 'package:flutter/material.dart';

void navigateAfterDelay(BuildContext context, dynamic page) {
  Future.delayed(Duration(milliseconds: 300), () {
    Navigator.of(context).push(routePage(page));
  });
  
}

Route routePage(dynamic nextPage) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 1000),
      pageBuilder: (context, animation, secondaryAnimation) => nextPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.fastLinearToSlowEaseIn;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }