import 'package:flutter/material.dart';
import 'package:transportumformanager/model/dashboard_item.dart';
import 'package:transportumformanager/model/dashboard_list.dart';
import 'package:transportumformanager/sections/home/dashboard/dashboard_expand.dart';
import 'package:transportumformanager/sections/home/home_api.dart';
import 'package:transportumformanager/sections/home/styles.dart';

class DashBoard extends StatefulWidget {
  final String dateString;
  final DashBoardListModel dashBoardList;
  DashBoard({Key key, this.dateString, this.dashBoardList}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  // pagelist item
  final List<Widget> widgetItems = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    widget.dashBoardList.items.forEach((item) {
      widgetItems.add(DashboardExpandedItem(dashBoardItemData: item));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widgetItems.isEmpty) {
      return Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.topCenter,
                child: Text("На этот день нет заявок...",
                    style: TextStyle(fontSize: 18, color: Colors.grey))),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(child: Image.asset('assets/cat.png', width: 200), opacity: 0.2)
          )
        ],
      );
    } else {
      return ListView(children: [
        Container(
          padding: paddings.var_5,
          child: Column(children: widgetItems),
        )
      ]);
    }
  }
}
