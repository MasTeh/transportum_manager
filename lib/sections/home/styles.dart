import 'package:flutter/material.dart';

mixin textStyles {
  static TextStyle style1 =
      const TextStyle(fontFamily: "Monserat", fontSize: 20);
  static TextStyle style2 =
      const TextStyle(fontFamily: "Monserat", fontSize: 18);
  static TextStyle style3 =
      TextStyle(fontFamily: "Monserat", fontSize: 18, color: Colors.indigo);

  static TextStyle smallBold =
      TextStyle(fontSize: 13, fontWeight: FontWeight.bold);
}

mixin paddings {
  static const var_3 = const EdgeInsets.all(3);
  static const var_5 = const EdgeInsets.all(5);
  static const var_10 = const EdgeInsets.all(10);
  static const var_15_10 =
      const EdgeInsets.symmetric(horizontal: 15, vertical: 10);
  static const var_5_10 =
      const EdgeInsets.symmetric(horizontal: 5, vertical: 10);
}
