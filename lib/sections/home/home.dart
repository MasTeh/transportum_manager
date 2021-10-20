import 'package:flutter/material.dart';
import 'package:transportumformanager/global/ChangesListener.dart';
import 'package:transportumformanager/global/InsideBuffer.dart';
import 'package:transportumformanager/global/appstorage/AppStorage.dart';
import 'package:transportumformanager/helper/routes.dart';
import 'package:transportumformanager/profile.dart';
import 'package:transportumformanager/sections/home/dashboard/dashboard_header.dart';
import 'package:transportumformanager/sections/home/dashboard/dashboard_pages.dart';
import 'package:transportumformanager/sections/order_edit/order_edit.dart';

import '../app_data/app_data.dart';
import 'package:logger/logger.dart';

final log = Logger();

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = AppData().clientName;

    AppStorage().updateAllStorages();

    return Scaffold(
        appBar: AppBar(title: Text(title), actions: [
          /*IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.of(context).push(routePage(ProfilePage()));
              }),*/
          IconButton(
              onPressed: () {
                Navigator.of(context).push(routePage(OrderEdit()));
              },
              icon: Icon(Icons.add))
        ]),
        body: Stack(
          children: [
            Container(
              child: Align(
                  alignment: FractionalOffset.topCenter,
                  child: DashBoardHeader()),
            ),
            Container(
              margin: EdgeInsets.only(top: 70),
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: DashBoardPages(
                  onChanged: (int index) {
                    InsideBuffer().put(InsideBuffers.dashboardPageIndex, index);
                    AppData()
                        .changeListener
                        .emitt(ChangesListeners.dashboardPageChanged);

                    if (index == 0 ||
                        index == ((AppData().dashboardPreloadCount * 2))) {
                      AppData()
                          .changeListener
                          .emitt(ChangesListeners.dashboardLoadNewStack);
                    }
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
