import 'package:flutter/material.dart';
import 'package:smart_select/smart_select.dart';

class CustomSmartSelectTile extends StatelessWidget {
  final S2SingleState<String> state;
  final Widget after;
  final String title;
  const CustomSmartSelectTile({Key key, this.state, this.after, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _title;
    var width = MediaQuery.of(context).size.width;

    if (this.title == null)
      _title = state.selected.title;
    else
      _title = this.title;

    var _textStyle;

    if (state.selected.value == "-1") _textStyle = TextStyle(color: Colors.red);

    return InkWell(
      onTap: () => state.showModal(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(state.title != null ? state.title : "",
                style: TextStyle(fontSize: 16)),
            Row(
              children: [
                _title != null
                    ? Container(
                        constraints: BoxConstraints(maxWidth: width * 0.7),
                        child: Text(_title, overflow: TextOverflow.clip, style: _textStyle))
                    : Text(""),
                Container(width: 5),
                after != null ? after : Container(),
                Container(width: 5),
                Icon(Icons.arrow_forward_ios, size: 14)
              ],
            )
          ],
        ),
      ),
    );
  }
}
