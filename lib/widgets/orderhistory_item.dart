import 'package:flutter/material.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';
import 'package:logger/logger.dart';
import 'package:transportumformanager/sections/order_details/order_details.dart';
import 'package:transportumformanager/widgets/blink_label.dart';

final log = Logger();

class OrderHistoryItem extends StatelessWidget {
  final int status;
  final String dateLabel;
  final String carnumber;
  final int orderId;
  final String cargoDesc;
  final String cargoType;
  final String labelTrailer;
  final String directionFrom;
  final String directionTo;
  final double hours;

  static int ORDER_SETTED = 0;
  static int ORDER_STARTED = 1;
  static int ORDER_DONE = 2;
  static int ORDER_CANCELLED = 3;

  const OrderHistoryItem(
      {@required this.status,
      @required this.dateLabel,
      @required this.carnumber,
      @required this.orderId,
      @required this.labelTrailer,
      @required this.cargoDesc,
      @required this.cargoType,
      this.directionFrom,
      this.hours,
      this.directionTo});

  @override
  Widget build(BuildContext context) {
    Widget _statusText;
    Widget _trailerText;
    Widget _fromToText;
    Widget _salaryText;

    if (status == OrderHistoryItem.ORDER_SETTED) {
      _statusText = Text("Назначена",
          style: TextStyle(color: Colors.grey[700], fontSize: 16));
    }

    if (status == OrderHistoryItem.ORDER_STARTED) {
      _statusText = BlinkLabel(
          millisecondsDuration: 200,
          text: Text("Выполняется...",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)));
    }

    if (status == OrderHistoryItem.ORDER_DONE) {
      _statusText = Text("Завершена",
          style: TextStyle(color: Colors.green[800], fontSize: 16));
    }

    if (labelTrailer == "С прицепом")
      _trailerText = Text(" + ПРИЦ", style: TextStyle(color: Colors.red[900]));
    else
      _trailerText = Container();

    String toPoint = "";
    if (directionTo != "") toPoint = " - " + directionTo;
    _fromToText = Padding(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Text(this.directionFrom + toPoint,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Monserat',
                fontSize: 16,
                color: Color(0xFF333333))));

    int salaryFromPrefs =
        AppData().prefs.getInt("salary_order_${this.orderId}");

    Widget hoursText = Container();
    Widget salaryText = Container();

    if (salaryFromPrefs != null) {
      salaryText = Text("$salaryFromPrefs руб", style: TextStyle(fontSize: 18));
    }

    if (hours > 0) {
      hoursText = Text("Часов водителя $hours",
          style: TextStyle(
              fontSize: 16,
              color: Colors.blue[900],
              fontWeight: FontWeight.bold));
    }

    _salaryText = Padding(
        padding: EdgeInsets.only(left: 15, right: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [hoursText, salaryText]));
            

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
                Text(dateLabel,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                Column(children: [
                  Text(carnumber,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF0046D9),
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  _trailerText,
                ]),
                Text("#$orderId",
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.black, fontSize: 14))
              ]),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child:
                  Divider(color: Color(0x99C5C2C2), height: 2, thickness: 2)),
          _fromToText,
          Container(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text("${this.cargoType}, ${this.cargoDesc}",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500))),
          _salaryText,
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderDetails(
                                title: "Заявка #$orderId", orderId: orderId)),
                      );
                    },
                    child: Text("Подробнее", style: TextStyle(fontSize: 16))),
                _statusText
              ])
        ]));
  }
}
