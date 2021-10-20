import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class Dialogs {
  static final runWayType_KM = 0;
  static final runWayType_HOURS = 1;

  static Future<void> showAlert(context, String title, String message,
      {Function okCallback}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: [Text(title)]),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Понятно',
                style: TextStyle(fontSize: 16, fontFamily: "Monserat"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (okCallback != null) okCallback();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> cameraChooseDialog(
      context, Function cameraChoose, Function galleryChoose) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return Dialog(
            child: Container(
          width: 160,
          height: 90,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Выберите источник фото",
                    style: TextStyle(fontSize: 16)),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      cameraChoose();
                    },
                    icon: Icon(Icons.camera_alt_outlined),
                    label: Text("Камера")),
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      galleryChoose();
                    },
                    icon: Icon(Icons.image_search_outlined),
                    label: Text("Галерея")),
              ]),
            ],
          ),
        ));
      },
    );
  }

  static Future<void> confirmDialog(context, String title, String message,
      {Function okCallback}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: [Text(title)]),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Понятно',
                style: TextStyle(fontSize: 16, fontFamily: "Monserat"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (okCallback != null) okCallback();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<String> promptDialog(context, String message,
      {String hint = ''}) async {
    return (await prompt(
      context,
      title: Text(message),
      initialValue: '',
      textOK: Text('Отправить'),
      textCancel: Text('Назад'),
      hintText: hint,
      minLines: 1,
      maxLines: 3,
      autoFocus: true,
      obscureText: false,
      obscuringCharacter: '•',
      textCapitalization: TextCapitalization.words,
    ));
  }

  static Future<void> checkRunDialog(context,
      {String firstValue,
      @required String transportId,
      @required int dataType,
      Function onResult}) async {
    await Future.delayed(Duration(milliseconds: 250));
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        TextEditingController inputController =
            TextEditingController(text: firstValue);

        String unit = "";
        String title = "Новые данные";
        if (dataType == Dialogs.runWayType_KM) {
          unit = "км";
          title = "Новые данные ПРОБЕГА";
        }
        if (dataType == Dialogs.runWayType_HOURS) {
          unit = "ч";
          title = "Новые данные МОТОЧАСОВ";
        }
        return Dialog(
            insetPadding: EdgeInsets.all(0),
            child: Container(
                width: 200,
                padding: EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18)),
                  Stack(children: [
                    Container(height: 10),
                    Align(
                        alignment: Alignment.center,
                        child: Container(
                            width: 150,
                            child: TextFormField(
                                controller: inputController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center))),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(unit, style: TextStyle(fontSize: 16)),
                        )),
                  ]),
                  Container(height: 10),
                  Stack(children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child:
                                Text("Назад", style: TextStyle(fontSize: 16)))),
                    Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                              onResult(inputController.text);
                            },
                            child: Text("Добавить",
                                style: TextStyle(fontSize: 16))))
                  ])
                ])));
      },
    );
  }

  static Future<void> showAlertWithWidgets(
      context, String title, List<Widget> widgets, String closeButton) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: [Text(title)]),
          content: SingleChildScrollView(
            child: ListBody(
              children: widgets,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(closeButton ?? "Ok",
                  style: TextStyle(fontSize: 16, fontFamily: "Roboto")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<dynamic> datePickerDialog(BuildContext context,
      {DateTime minTime, DateTime maxTime, DateTime currentDateTime}) {
    if (currentDateTime == null) currentDateTime = DateTime.now();
    Completer completer = Completer();
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: minTime,
        maxTime: maxTime,
        theme: DatePickerTheme(
            itemStyle: TextStyle(color: Colors.black, fontSize: 18),
            doneStyle: TextStyle(color: Colors.blue, fontSize: 16)),
        onChanged: (date) {}, onConfirm: (date) {
      completer.complete(date);
    }, currentTime: currentDateTime, locale: LocaleType.ru);
    return completer.future;
  }

  static Future<dynamic> dateTimePickerDialog(BuildContext context,
      {DateTime minTime,
      DateTime maxTime,
      DateTime currentDateTime,
      Function onchanged}) {
    DateTime _now = DateTime.now();
    if (currentDateTime == null)
      currentDateTime = DateTime(_now.year, _now.month, _now.day, 12, 0);

    Completer completer = Completer();
    DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        minTime: minTime,
        maxTime: maxTime,
        theme: DatePickerTheme(
            itemStyle: TextStyle(color: Colors.black, fontSize: 18),
            doneStyle: TextStyle(color: Colors.blue, fontSize: 16)),
        onChanged: (date) {
      if (onchanged != null) onchanged(date);
    }, onConfirm: (date) {
      completer.complete(date);
    }, currentTime: currentDateTime, locale: LocaleType.ru);
    return completer.future;
  }
}
