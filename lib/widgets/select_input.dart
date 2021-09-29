import 'package:flutter/material.dart';

class SelectInput extends StatefulWidget {
  final String label;
  final String initialValue;
  final Map<String, String> items;
  final TextEditingController controller;
  final Function onChange;
  final bool disabled;

  static bool isEmpty(TextEditingController controller) {
    if (controller.text == "__null") return true;
    if (controller.text == "") return true;
    if (controller.text.isEmpty) return true;

    return false;
  }

  const SelectInput(
      {@required this.label,
      @required this.items,
      this.initialValue = "__null",
      this.controller,
      this.disabled = false,
      this.onChange});

  @override
  _SelectInputState createState() => _SelectInputState();
}

class _SelectInputState extends State<SelectInput> {
  List<DropdownMenuItem> _widgetItems = [];

  String selectValue;
  TextEditingController controller;
  Function onChange;

  @override
  void initState() {
    super.initState();
    _widgetItems = [];

    selectValue = widget.initialValue;
    controller = widget.controller;
    onChange = widget.onChange;

    _widgetItems
        .add(DropdownMenuItem(value: "__null", child: Text("не выбрано")));
    widget.items.forEach((key, value) {
      _widgetItems.add(DropdownMenuItem(value: key, child: Text(value)));
    });
  }

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;

    Widget _dropDown = DropdownButton(
        isExpanded: true,
        value: selectValue,
        onChanged: (value) {
          selectValue = value;
          if (controller != null) controller.text = value;
          setState(() {});
          if (widget.onChange != null) widget.onChange();
        },
        items: _widgetItems);

    if (widget.disabled)
      _dropDown = DropdownButton(
          isExpanded: true,
          value: selectValue,
          onChanged: null,
          items: _widgetItems);

    return Container(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(width: mediaWidth * 0.4, child: Text(this.widget.label)),
      Container(
        width: mediaWidth * 0.5,
        child: _dropDown,
      )
    ]));
  }
}
