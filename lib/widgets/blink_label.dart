import 'package:flutter/material.dart';

class BlinkLabel extends StatefulWidget {
  @required
  final Text text;
  @required
  final int millisecondsDuration;
  BlinkLabel({Key key, this.text, this.millisecondsDuration}) : super(key: key);

  @override
  _BlinkLabelState createState() =>
      _BlinkLabelState(text: text, millisecondsDuration: millisecondsDuration);
}

class _BlinkLabelState extends State<BlinkLabel>
    with SingleTickerProviderStateMixin {
  final Text text;
  final int millisecondsDuration;
  AnimationController _animationController;

  _BlinkLabelState({this.text, this.millisecondsDuration});

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: this.millisecondsDuration),
        lowerBound: 0.3);

    _animationController.repeat(reverse: true);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _animationController.stop();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FadeTransition(opacity: _animationController, child: this.text),
    );
  }
}
