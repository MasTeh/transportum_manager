import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  @required final String label;  
  @required final IconData iconData;
  final TextStyle textStyle;
  const TextIcon({Key key, this.label, this.textStyle, this.iconData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _textStyle = TextStyle(fontSize: 16, color: Colors.black);
    if (textStyle == null) _textStyle = textStyle;
    return RichText(
        text: TextSpan(children: [
      WidgetSpan(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(iconData, color: _textStyle.color, size: (_textStyle.fontSize + 2)),
          )),
      TextSpan(text: label, style: _textStyle)
    ]));
  }
}
