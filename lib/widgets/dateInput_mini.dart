import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:transportumformanager/helper/dialogs.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateTimeInputMini extends StatefulWidget {
  final TextEditingController controllerForWeb;
  final TextEditingController controllerForLabel;
  final String helperText;
  final Color textColor;
  final DateTime minDateTime;
  final DateTime maxDateTime;
  DateTime currentDateTime;
  final double width;
  final Function afterChange;

  DateTimeInputMini(
      {Key key,
      @required this.controllerForWeb,
      @required this.width,
      this.helperText,
      this.textColor = Colors.black,
      this.maxDateTime,
      this.minDateTime,
      this.currentDateTime,
      this.afterChange,
      @required this.controllerForLabel})
      : super(key: key);

  @override
  _DateTimeInputMiniState createState() => _DateTimeInputMiniState();
}

class _DateTimeInputMiniState extends State<DateTimeInputMini> {
  TextEditingController dateForWebController;
  TextEditingController dateForLabelController;

  @override
  void initState() {
    super.initState();
    dateForWebController = widget.controllerForWeb;
    dateForLabelController = widget.controllerForLabel;

    initializeDateFormatting('ru', null).then((value) {
      if (widget.currentDateTime != null) {
        setDate(widget.currentDateTime);
      }
    });
    if (dateForWebController.text.isNotEmpty)
      widget.currentDateTime = DateTime.parse(dateForWebController.text);
  }

  void setDate(DateTime dateResult) {
    widget.currentDateTime = dateResult;
    setState(() {});
  }

  void updateDateLabels() {
    if (widget.currentDateTime != null) {
      dateForWebController.text =
          DateFormat('yyyy-MM-dd').format(widget.currentDateTime);
      dateForLabelController.text =
          DateFormat.yMMMd('ru').format(widget.currentDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    updateDateLabels();

    print(widget.currentDateTime.toString());

    return Container(
      width: widget.width,
      child: TextField(
        autofocus: false,
        controller: dateForLabelController,
        style: TextStyle(fontSize: 16),
        readOnly: true,
        onTap: () async {
          var result = await Dialogs.datePickerDialog(context,
              currentDateTime: widget.currentDateTime,
              maxTime: widget.maxDateTime,
              minTime: widget.minDateTime);
          DateTime dateResult = DateTime.parse(result.toString());

          setDate(dateResult);

          if (widget.afterChange != null) widget.afterChange(widget.currentDateTime);
        },
        decoration: InputDecoration(
            helperText: widget.helperText,
            labelStyle: TextStyle(
                color: widget.textColor, fontSize: 16, fontFamily: "Monserat")),
      ),
    );
  }
}
