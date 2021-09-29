import 'package:flutter/material.dart';
import 'package:transportumformanager/sections/order_details/order_details.dart';
import 'package:transportumformanager/network/socket.dart';
import 'package:transportumformanager/helper/dialogs.dart';

class OrderItem extends StatelessWidget {
  final int status;
  final String time;
  final String carnumber;
  final int orderId;
  final String cargoType;
  final String cargoDesc;
  final String problem;
  final Function setProblemFunc;
  final Function removeProblemFunc;
  final String trailerLabel;

  static int ORDER_SETTED = 0;
  static int ORDER_STARTED = 1;
  static int ORDER_DONE = 2;
  static int ORDER_PROBLEM = 3;

  const OrderItem(
      {this.status = 0,
      this.problem = '',
      @required this.time,
      @required this.carnumber,
      @required this.orderId,
      @required this.cargoType,
      @required this.cargoDesc,
      @required this.setProblemFunc,
      @required this.trailerLabel,
      @required this.removeProblemFunc});

  @override
  Widget build(BuildContext context) {
    String _trailerWidgetLabel = "";
    Widget _statusLine;
    Widget _orderButton;

    if (trailerLabel == "С прицепом") _trailerWidgetLabel = " + ПРИЦ";

    Widget problemButton = Container();

    if (status == OrderItem.ORDER_SETTED) {
      _statusLine = Row();
      _orderButton = RaisedButton(
          onPressed: () {
            // order action button
          },
          color: Colors.green[800],
          textColor: Colors.white,
          child: Text("Начать"));
    }

    if (status == OrderItem.ORDER_STARTED ||
        status == OrderItem.ORDER_PROBLEM) {
      if (problem == "") {
        problemButton = FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: setProblemFunc,
            padding: EdgeInsets.all(5),
            child: Row(children: <Widget>[
              Icon(Icons.error_outline, color: Colors.red[700], size: 20),
              Text("Проблема?",
                  style: TextStyle(fontSize: 16, color: Colors.red[700])),
            ]));
      } else {
        problemButton = FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.red[700],
            onPressed: removeProblemFunc,
            padding: EdgeInsets.all(5),
            child: Row(children: <Widget>[
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              Text("Убрать проблему",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ]));
      }

      _statusLine = Column(children: <Widget>[
        Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Divider(color: Color(0x99C5C2C2), height: 2, thickness: 2)),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Выполняется',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              problemButton
            ]),
        Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Divider(color: Color(0x99C5C2C2), height: 2, thickness: 2))
      ]);

      _orderButton = RaisedButton(
          onPressed: () {
            // order action button
          },
          color: Colors.red[900],
          textColor: Colors.white,
          child: Text("Завершить"));
    }

    return Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.2))
        ], color: Colors.white),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(top: 10),
        child: Column(children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(time,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                Text(carnumber + _trailerWidgetLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF0046D9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text("#$orderId",
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.black, fontSize: 14))
              ]),
          _statusLine,
          Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Text(this.cargoType,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Monserat',
                      fontSize: 18,
                      color: Color(0xFF333333)))),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
              child: Text(this.cargoDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      // about button
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderDetails(
                                title: "Заявка #$orderId", orderId: orderId)),
                      );
                    },
                    child: Text("Подробнее", style: TextStyle(fontSize: 16))),
                //_orderButton
              ])
        ]));
  }
}
