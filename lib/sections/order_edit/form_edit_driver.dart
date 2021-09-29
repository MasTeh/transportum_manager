import 'package:flutter/material.dart';
import 'package:transportumformanager/global/appstorage/AppStorage.dart';
import 'package:smart_select/smart_select.dart';
import 'package:transportumformanager/helper/log.dart';
import 'package:transportumformanager/model/user_driver.dart';

import 'custom_tile.dart';

class FormEditDriver extends StatelessWidget {
  final TextEditingController controller;
  const FormEditDriver({Key key, this.controller}) : super(key: key);

  List<S2Choice<String>> getDriverItems() {
    List<S2Choice<String>> _resultItems = [];
    _resultItems
        .add(S2Choice<String>(title: "не указано", value: "-1", group: ""));

    AppStorage().drivers.forEach((driverId, driverItem) {
      if (!driverItem.isDeleted)
        _resultItems.add(S2Choice<String>(
            style: S2ChoiceStyle(
                titleStyle: driverItem.isOwn
                    ? TextStyle(
                        color: Colors.green[700], fontWeight: FontWeight.bold)
                    : null),
            value: driverItem.id.toString(),
            title: driverItem.fullFIO()));
    });

    return _resultItems;
  }

  @override
  Widget build(BuildContext context) {
    print("DRIVER " + controller.text);
    return SmartSelect<String>.single(
      tileBuilder: (context, state) {
        String _value = controller.text;
        UserDriver _driver = AppStorage().getDriverSafe(int.parse(_value));

        if (_driver == null || _driver.isDeleted) {
          _driver = null;
          _value = "-1";
        }

        state.selected.value = _value;

        return CustomSmartSelectTile(
            state: state,
            after: _value != "-1"
                ? Icon(Icons.person,
                    color: _driver.isOwn ? Colors.green : Colors.grey)
                : null,
            title: _driver != null ? _driver.shortFIO() : "не указано");
      },
      selectedValue: controller.text,
      modalFilter: true,
      modalFilterHint: "поиск",
      modalFilterAuto: true,
      onChange: (state) {
        controller.text = state.value;
        print(state.value);
      },
      title: "Водитель",
      choiceItems: getDriverItems(),
    );
  }
}
