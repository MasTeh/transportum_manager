import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:transportumformanager/model/dashboard_item.dart';
import 'package:transportumformanager/model/order.dart';
import 'package:transportumformanager/sections/home/dashboard/dashboard_order.dart';
import '../styles.dart';
import 'dashboard_item.dart';

class DashboardExpandedItem extends StatelessWidget {
  final DashBoardItemModel dashBoardItemData;

  const DashboardExpandedItem({Key key, this.dashBoardItemData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final border1 = BorderSide(color: Colors.grey[200], width: 2);
    final border2 = BorderSide(color: Colors.white, width: 2);
    final expandController = ExpandableController(initialExpanded: false);

    final List<Widget> _ordersWidgets = [];

    dashBoardItemData.orders.forEach((order) {
      _ordersWidgets.add(DashboardOrder(orderModel: order));
    });

    return Container(
      decoration: BoxDecoration(border: Border(top: border2, bottom: border1)),
      child: ExpandablePanel(
          controller: expandController,
          theme: ExpandableThemeData(
              useInkWell: true,
              hasIcon: true,
              iconPadding: EdgeInsets.only(top: 15)),
          header: DashboardItem(dashBoardItemModel: dashBoardItemData),
          expanded: Container(
              child: Column(children: _ordersWidgets))),
    );
  }
}
