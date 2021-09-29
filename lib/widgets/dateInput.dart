import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:transportumformanager/helper/dialogs.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateInput extends StatefulWidget {
  final TextEditingController controllerForWeb;
  final TextEditingController controllerForLabel;
  final String label;
  final String helperText;
  final Function validator;
  final Color textColor;
  final bool confirm;
  final BuildContext context;
  final DateTime minDateTime;
  final DateTime maxDateTime;

  DateInput(
      {Key key,
      @required this.label,
      @required this.controllerForWeb,
      this.validator,
      this.confirm = false,
      this.context,
      this.helperText,
      this.textColor = Colors.black,
      this.maxDateTime,
      this.minDateTime,
      this.controllerForLabel})
      : super(key: key);

  @override
  _DateInputState createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  TextEditingController dateForWebController;
  TextEditingController dateForLabelController;

  @override
  void initState() {
    super.initState();
    dateForWebController = widget.controllerForWeb;
    dateForLabelController = widget.controllerForLabel;
  }

  void setDate(dateResult) {
    dateForWebController.text = DateFormat('yyyy-MM-dd').format(dateResult);
    dateForLabelController.text = DateFormat.yMMMMd('ru').format(dateResult);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ru', null);
    DateTime currentDate;
    if (dateForWebController.text.isNotEmpty)
      currentDate = DateTime.parse(dateForWebController.text);

    return TextFormField(
      autofocus: false,
      controller: dateForLabelController,
      style: TextStyle(fontSize: 16),
      readOnly: true,
      validator: widget.validator,
      onTap: () async {
        var result = 
            await Dialogs.datePickerDialog(context, currentDateTime: currentDate, maxTime: widget.maxDateTime, minTime: widget.minDateTime);
        DateTime dateResult = DateTime.parse(result.toString());

        if (widget.confirm) {
          if (await confirm(
            context,
            title: Text('Подтверждение'),
            content: Text('Вы выбрали дату ' +
                DateFormat.yMMMMd('ru').format(dateResult)),
            textOK: Text('Да'),
            textCancel: Text('Нет'),
          )) {
            setDate(dateResult);
          }
        } else {
          setDate(dateResult);
        }
      },
      decoration: InputDecoration(
          labelText: widget.label,
          helperText: widget.helperText,
          labelStyle: TextStyle(
              color: widget.textColor, fontSize: 16, fontFamily: "Monserat")),
    );
  }
}
