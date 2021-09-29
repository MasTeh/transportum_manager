import 'package:flutter/material.dart';
import 'package:transportumformanager/helper/routes.dart';
import 'package:transportumformanager/model/dashboard_item.dart';
import 'package:transportumformanager/model/order.dart';
import 'package:transportumformanager/sections/order_details/order_details.dart';
import '../styles.dart';

//это непосредственно заявка в графике

class DashboardOrder extends StatelessWidget {
  final OrderModel orderModel;
  const DashboardOrder({Key key, this.orderModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;

    Widget _trailerWidget = Container();
    if (orderModel.haveTrailer) {
      _trailerWidget = Container(
        padding: paddings.var_3,
        width: _screenWidth * 0.9,
        child: Text(orderModel.getTrailerLabelLong(),
            style: const TextStyle(fontSize: 14, color: Colors.black)),
      );
    }

    return Container(
        decoration: BoxDecoration(color: Colors.green[50]),
        margin: EdgeInsets.only(bottom: 5),
        child: Material(
          color: Colors.transparent,
          child: InkWell(            
            highlightColor: Colors.white.withAlpha(200),
            splashColor: Colors.white,            
            onTap: () {
              navigateAfterDelay(context, OrderDetails(orderId: orderModel.id, title: "Заявка № ${orderModel.id}"));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                Container(
                  padding: paddings.var_3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(orderModel.time,
                              style: TextStyle(fontSize: 20, color: Colors.indigo)),
                          Text(orderModel.managerLogin,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.green[800])),
                          Text(orderModel.getStatusLabel(),
                              style: orderModel.getStatusLabelStyle()),
                          Text("#${orderModel.id}",
                              style: TextStyle(fontSize: 14, color: Colors.black87))
                        ]),
                  ),
                ),
                Container(
                  padding: paddings.var_3,
                  width: _screenWidth * 0.9,
                  child: Text(orderModel.companyName,
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
                Container(
                  padding: paddings.var_3,
                  width: _screenWidth * 0.9,
                  child: Text(
                      "${orderModel.addressFromShort} → ${orderModel.addressDestShort}",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[900],
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: paddings.var_3,
                  width: _screenWidth * 0.9,
                  child: Text(orderModel.cargoType,
                      style: TextStyle(fontSize: 14, color: Colors.black87)),
                ),
              ]),
            ),
          ),
        ));
  }
}
