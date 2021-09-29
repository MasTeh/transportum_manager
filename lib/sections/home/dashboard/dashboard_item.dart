import 'package:flutter/material.dart';
import 'package:transportumformanager/model/dashboard_item.dart';
import 'order_point.dart';
import '../styles.dart';

class DashboardItem extends StatelessWidget {
  final DashBoardItemModel dashBoardItemModel;
  const DashboardItem({Key key, this.dashBoardItemModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width*0.9;
    final _carIconOwn = Image.asset("assets/truck.png");
    final _carIconRent = Image.asset("assets/truck_rent.png");
    final BoxDecoration _itemDecor = BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(width: 2, color: Colors.grey[200])));

    Widget _carIcon;
    if (dashBoardItemModel.isOwnTransport)
      _carIcon = _carIconOwn;
    else
      _carIcon = _carIconRent;

    List<Widget> ordesPoints = [];

    dashBoardItemModel.orders.forEach((element) {
      ordesPoints.add(DashboardOrderPoint(orderState: element.status));
    });

    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(padding: paddings.var_5, width: 50, child: _carIcon),
        Container(
            padding: paddings.var_5,
            width: _screenWidth * 0.3,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: ordesPoints)),
        Text(dashBoardItemModel.transportNumber, style: textStyles.style3)
      ]),
    );
  }
}
