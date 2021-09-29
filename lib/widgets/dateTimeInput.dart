import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:transportumformanager/helper/dialogs.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateTimeInput extends StatefulWidget {
  @required
  final TextEditingController controllerForWeb;
  final TextEditingController controllerForLabel;
  final TextEditingController controllerForTime;
  final String label;
  final String helperText;
  final Function validator;
  final Function onChanged;
  final Function onConfirmChanged;
  final Color textColor;
  final bool confirm;
  final BuildContext context;
  final DateTime minDateTime;
  final DateTime maxDateTime;

  DateTimeInput(
      {Key key,
      @required this.label,
      @required this.controllerForWeb,
      this.validator,
      this.onChanged,
      this.onConfirmChanged,
      this.confirm = false,
      this.context,
      this.helperText,
      this.textColor = Colors.black,
      this.maxDateTime,
      this.minDateTime,
      this.controllerForLabel,
      this.controllerForTime})
      : super(key: key);

  @override
  _DateTimeInputState createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  TextEditingController dateForWebController;
  TextEditingController dateForLabelController;
  TextEditingController timeController;

  @override
  void initState() {
    super.initState();
    dateForWebController = widget.controllerForWeb;
    dateForLabelController = widget.controllerForLabel;
    timeController = widget.controllerForTime;
  }

  void setDate(dateResult) {
    dateForWebController.text = DateFormat('yyyy-MM-dd').format(dateResult);
    timeController.text = DateFormat('HH:mm').format(dateResult);
    dateForLabelController.text = DateFormat.yMMMMd('ru').format(dateResult) +
        ' время ' +
        timeController.text;
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
        var result = await Dialogs.dateTimePickerDialog(context,
            currentDateTime: currentDate,
            onchanged: widget.onChanged,
            maxTime: widget.maxDateTime,
            minTime: widget.minDateTime);
        DateTime dateResult = DateTime.parse(result.toString());

        if (widget.confirm) {
          if (await confirm(
            context,
            title: Text('Подтверждение'),
            content: Text('Вы выбрали дату ' +
                DateFormat.yMMMMd('ru').format(dateResult) +
                ' и время ' +
                DateFormat('HH:mm').format(dateResult) +
                '?'),
            textOK: Text('Да'),
            textCancel: Text('Нет'),
          )) {
            setDate(dateResult);
            if (widget.onConfirmChanged != null) widget.onConfirmChanged(dateResult);
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
