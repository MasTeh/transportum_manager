import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppStyles {
  
  static TextStyle darkText({double size}) {
    double textSize = 14;
    if (size != null) textSize = size;
    return TextStyle(
        fontFamily: "Monserat", fontSize: textSize, color: Colors.black);
  }

  static TextStyle grayText({double size}) {
    double textSize = 14; 
    if (size != null) textSize = size;
    return TextStyle(
        fontFamily: "Monserat", fontSize: textSize, color: Colors.black54);
  }
}