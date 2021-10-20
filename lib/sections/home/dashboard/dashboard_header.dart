import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transportumformanager/global/ChangesListener.dart';
import 'package:transportumformanager/global/InsideBuffer.dart';
import 'package:transportumformanager/helper/weekdays_names.dart';
import 'package:transportumformanager/interface/ActivePage.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';
import 'package:transportumformanager/widgets/dateInput_mini.dart';
import 'package:transportumformanager/sections/home/styles.dart';

class DashBoardHeader extends StatefulWidget {
  DashBoardHeader({Key key}) : super(key: key);

  @override
  _DashBoardHeaderState createState() => _DashBoardHeaderState();
}

class _DashBoardHeaderState extends State<DashBoardHeader>
    implements ActivePage {
  final TextEditingController _dateWeb = TextEditingController();
  final TextEditingController _dateLabel = TextEditingController();

  DateTime _dateTime;
  String weekDay;

  @override
  String changeListenerName = ChangesListeners.dashboardPageChanged;

  @override
  void initChangeListener() {
    AppData()
        .changeListener
        .setListener(changeListenerName, this.onChangeListener);
  }

  @override
  void onChangeListener() {
    int pageIndex = InsideBuffer()
        .get(InsideBuffers.dashboardPageIndex); // получаем дату конкретно

    _dateTime = InsideBuffer().dashboardDateSync[pageIndex];

    updateDate();

    setState(() {});
  }

  void setNextDay() {
    _dateTime = _dateTime.add(Duration(days: 1));
    updateDate();
    setState(() {});
  }

  void setPrevDay() {
    _dateTime = _dateTime.subtract(Duration(days: 1));
    updateDate();
    setState(() {});
  }

  void updateDate() {
    weekDay = WeekdaysLong.names[_dateTime.weekday];

    InsideBuffer()
        .put(InsideBuffers.dashboardDate, _dateTime, notclearFlag: true);
  }

  @override
  void initState() {
    super.initState();

    this.initChangeListener();

    _dateTime = DateTime.now();
    _dateTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day, 9, 0);
    weekDay = WeekdaysLong.names[_dateTime.weekday];

    InsideBuffer()
        .put(InsideBuffers.dashboardDate, _dateTime, notclearFlag: true);
  }

  @override
  void dispose() {
    AppData().changeListener.removeListener(changeListenerName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: paddings.var_15_10,
        decoration: BoxDecoration(
            color: Colors.yellow[50],
            border: Border(
                bottom:
                    BorderSide(width: 2, color: Colors.black.withAlpha(20)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(weekDay, style: textStyles.style1),
            DateTimeInputMini(
              width: 100,
              currentDateTime: _dateTime,
              controllerForLabel: _dateWeb,
              controllerForWeb: _dateLabel,
              minDateTime: DateTime(_dateTime.year - 2, 1, 1),
              maxDateTime: DateTime(_dateTime.year + 2, 1, 1),
              afterChange: (newDate) {
                _dateTime = newDate;
                updateDate();
                setState(() {});
                AppData()
                    .changeListener
                    .emitt(ChangesListeners.dashboardLoadNewStack);
              },
            )
          ],
        ));
  }
}
