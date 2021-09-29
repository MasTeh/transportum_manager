import 'package:flutter/material.dart';

class FlatButtonWithIcon extends StatelessWidget {
  @required
  final IconData icon;
  @required
  final Function onclick;
  @required
  final String text;
  @required
  final Color color;
  @required
  final double fontSize;
  final bool specFont;
  final double maxWidth;
  final bool truncate;

  const FlatButtonWithIcon(
      {Key key,
      this.icon,
      this.text,
      this.onclick,
      this.color,
      this.maxWidth,
      this.truncate,
      this.fontSize,
      this.specFont})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = this.fontSize + 4;
    bool useSpecFont = false;
    if (this.specFont == null)
      useSpecFont = false;
    else
      useSpecFont = true;

    TextOverflow _textOverflow = TextOverflow.clip;
    if (this.truncate == true) _textOverflow = TextOverflow.ellipsis;

    BoxConstraints _constraints = BoxConstraints();
    if (this.maxWidth != null)
      _constraints = BoxConstraints(maxWidth: this.maxWidth);

    TextStyle style = TextStyle(fontSize: this.fontSize, color: color);
    if (useSpecFont)
      style = TextStyle(
          fontSize: this.fontSize, color: color, fontFamily: "Monserat");

    return Container(
        child: FlatButton(
      child: Row(children: [
        Padding(
            padding: EdgeInsets.only(right: 6),
            child: Icon(this.icon, size: iconSize, color: this.color)),
        Container(
            constraints: _constraints,
            child: Text(this.text, style: style, overflow: _textOverflow))
      ]),
      onPressed: this.onclick,
    ));
  }
}
