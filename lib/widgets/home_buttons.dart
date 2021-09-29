import 'package:flutter/material.dart';

class MainScreenButton extends StatelessWidget {
  Color color;
  String name;
  int count;
  double width;
  Icon icon;
  double labelPadding;
  Function onclick;
  bool disabled;

  MainScreenButton(
      {String name,
      int count,
      Color color,
      double width,
      Icon icon,
      bool disabled = false,
      Function onclick,
      double labelPadding}) {
    this.color = color;
    this.name = name;
    this.count = count;
    this.width = width;
    this.disabled = disabled;
    this.icon = icon;
    this.onclick = onclick;

    if (labelPadding == null)
      this.labelPadding = 10;
    else
      this.labelPadding = labelPadding;
  }

  @override
  Widget build(BuildContext context) {
    String badgeStr = "+$count";
    if (count == 0 || count == null) badgeStr = " ";

    var buttonAction = onclick;
    if (disabled) buttonAction = null;

    var buttonColor = color;
    if (disabled) buttonColor = Colors.grey[600];

    return Container(
        margin: EdgeInsets.all(3),
        child: RaisedButton(
            color: buttonColor,
            padding: EdgeInsets.all(0),
            onPressed: () async {
              await Future.delayed(const Duration(milliseconds: 220));
              buttonAction();
            },
            child: Container(
                height: 115,
                alignment: Alignment.center,
                width: width,
                child: Column(children: <Widget>[
                  Container(
                      alignment: Alignment.topRight,
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(badgeStr,
                              style: TextStyle(
                                  color: Colors.yellow[200],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)))),
                  Container(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: EdgeInsets.only(top: labelPadding),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                icon,
                                Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Container(
                                        //width: 100,
                                        child: Text(name,
                                            style: TextStyle(
                                                fontFamily: 'Monserat',
                                                color: Colors.white,
                                                fontSize: 16))))
                              ])))
                ]))));
  }
}
