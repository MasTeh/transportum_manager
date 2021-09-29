import 'package:flutter/material.dart';
import 'package:transportumformanager/model/order.dart';

mixin _paddings {
  static const var_2 = const EdgeInsets.all(2);
  static const var_3 = const EdgeInsets.all(3);
  static const var_5 = const EdgeInsets.all(5);
}


// точка обозначающая заявку

class DashboardOrderPoint extends StatefulWidget {
  @required
  final int orderState;
  DashboardOrderPoint({Key key, this.orderState}) : super(key: key);

  @override
  DashboardOrderPointState createState() => DashboardOrderPointState();
}

class DashboardOrderPointState extends State<DashboardOrderPoint>
    with SingleTickerProviderStateMixin {
  final double _size = 12;

  AnimationController _animationController;
  Widget _resultWidget;

  @override
  void initState() { 
    if (widget.orderState == OrderStates.setted) {
      _resultWidget =
          Container(color: Colors.grey, width: _size, height: _size);
    }

    if (widget.orderState == OrderStates.done) {
      _resultWidget =
          Container(color: Colors.green[600], width: _size, height: _size);
    }

    if (widget.orderState == OrderStates.problem) {
      _resultWidget =
          Container(color: Colors.red[800], width: _size, height: _size);
    }

    if (widget.orderState == OrderStates.sended1c) {
      _resultWidget =
          Container(color: Colors.yellow[600], width: _size, height: _size);
    }

    if (widget.orderState == OrderStates.paid1c) {
      _resultWidget =
          Container( 
            width: _size, 
            height: _size,             
            child: Image.asset('assets/icon-check.png',alignment: Alignment.center, fit: BoxFit.contain));
    }

    if (widget.orderState == OrderStates.active) {
      _animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 300), lowerBound: 0.3);

      _animationController.repeat(reverse: true);

      _resultWidget = FadeTransition(
          opacity: _animationController,
          child: Container(color: Colors.green, width: _size, height: _size));
    }

    super.initState();
  }

  @override
  void dispose() {
    if (widget.orderState == OrderStates.active) {
      _animationController.stop();
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(padding: _paddings.var_3, child: _resultWidget);
  }
}
