import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:transportumformanager/global/ChangesListener.dart';
import 'package:transportumformanager/global/InsideBuffer.dart';
import 'package:transportumformanager/interface/ActivePage.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';
import 'package:transportumformanager/sections/home/dashboard.dart';
import 'package:transportumformanager/sections/home/home_api.dart';
import 'package:transportumformanager/widgets/preloaders.dart';

final log = Logger();

/*
  void Function(Map<String, dynamic> jsonData) onSuccess;

  LoginApi setOnErrorListener(Function(String message) callback) {
    this.onError = callback;
    return this;
  }
  */
class DashBoardPages extends StatefulWidget {
  final Function onChanged;
  final Function onPrevPage;
  final Function onNextPage;
  DashBoardPages({Key key, this.onChanged, this.onNextPage, this.onPrevPage})
      : super(key: key);

  @override
  _DashBoardPagesState createState() => _DashBoardPagesState();
}

class _DashBoardPagesState extends State<DashBoardPages> implements ActivePage {
  PageController _pageController;
  int currentIndex = AppData().dashboardPreloadCount;

  var currentPageValue = 0.0;

  bool isLoading = true;

  final List<Widget> pages = [];

  @override
  String changeListenerName = ChangesListeners.dashboardLoadNewStack;

  @override
  void initChangeListener() {
    AppData()
        .changeListener
        .setListener(changeListenerName, this.onChangeListener);
  }

  @override
  void onChangeListener() {
    reloadPages();
  }

  @override
  void initState() {
    super.initState();

    initChangeListener();

    _pageController = PageController(initialPage: currentIndex);
    _pageController.addListener(() {
      setState(() {
        currentPageValue = _pageController.page;
      });
    });
    reloadPages();
  }

  @override
  void dispose() {
    AppData().changeListener.removeListener(changeListenerName);

    super.dispose();
  }

  void reloadPages() async {
    pages.clear();

    DateTime _dashBoardDate = InsideBuffer().get(InsideBuffers.dashboardDate,
        notErrIfNotFound: true, defaultValue: null);

    if (_dashBoardDate == null) _dashBoardDate = DateTime.now();

    List<String> datesStr = [];
    final count = AppData().dashboardPreloadCount;

    List<DateTime> _dashboardDateSync = [];

    for (int i = (-1) * count; i < 0; i++) {
      DateTime _offsetDate = _dashBoardDate.subtract(Duration(days: i));
      datesStr.add(DateFormat('yyyy-MM-dd').format(_offsetDate));
      _dashboardDateSync.add(_offsetDate);
    }

    datesStr.add(DateFormat('yyyy-MM-dd').format(_dashBoardDate));
    _dashboardDateSync.add(_dashBoardDate);

    for (int i = 1; i <= count; i++) {
      DateTime _offsetDate = _dashBoardDate.subtract(Duration(days: i));
      datesStr.add(DateFormat('yyyy-MM-dd').format(_offsetDate));
      _dashboardDateSync.add(_offsetDate);
    }

    datesStr = datesStr.reversed.toList();

    InsideBuffer().dashboardDateSync = _dashboardDateSync.reversed.toList();

    isLoading = true;
    setState(() {});

    await Future.forEach(datesStr, (_elemDate) async {
      var _dashboard = await HomeApi().getDashBoardPage(_elemDate);

      pages.add(DashBoard(
        dateString: _elemDate,
        dashBoardList: _dashboard,
      ));
    });

    isLoading = false;
    setState(() {});
  }

  void onChange(int changedIndex) {
    if (changedIndex > currentIndex) {
      if (widget.onNextPage != null) widget.onNextPage();
    }

    if (changedIndex < currentIndex) {
      if (widget.onPrevPage != null) widget.onPrevPage();
    }

    if (widget.onChanged != null) {
      widget.onChanged(changedIndex);
    }

    this.currentIndex = changedIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CenterPreloader();
    } else {
      return PageView.builder(
          controller: _pageController,
          onPageChanged: onChange,
          itemBuilder: (context, position) {
            double _opacity = 1;
            double _diff = position - currentPageValue;
            if (_diff > 0)
              _opacity = _diff;
            else
              _opacity = _diff * (-1);

            

            if (_opacity > 1) _opacity = 1;
            if (position == currentPageValue.floor()) {
              return Opacity(
                opacity: (1 - _opacity),
                child: Transform(
                  transform: Matrix4.identity()
                    ..scale(1 + ((position - currentPageValue) / 5)),
                  child: pages[position],
                ),
              );
            } else if (position == currentPageValue.floor() + 1) {
              return Opacity(
                opacity: (1 - _opacity),
                child: Transform(
                  transform: Matrix4.identity()
                    ..scale(1 - ((position - currentPageValue) / 5)),
                  child: pages[position],
                ),
              );
            } else {
              return pages[position];
            }
          });
      // return PageView(
      //   allowImplicitScrolling: false,
      //   controller: _pageController,
      //   onPageChanged: onChange,
      //   children: pages,
      // );
    }
  }
}
