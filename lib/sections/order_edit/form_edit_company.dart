import 'package:flutter/material.dart';
import 'package:transportumformanager/global/appstorage/AppStorage.dart';
import 'package:smart_select/smart_select.dart';
import 'package:transportumformanager/helper/log.dart';
import 'package:transportumformanager/model/user_driver.dart';

import 'custom_tile.dart';

class FormEditCompany extends StatelessWidget {
  final TextEditingController controller;
  const FormEditCompany({Key key, this.controller}) : super(key: key);

  List<S2Choice<String>> getItems() {
    List<S2Choice<String>> _resultItems = [];
    _resultItems
        .add(S2Choice<String>(title: "не указано", value: "-1"));

    AppStorage().companies.forEach((companyId, companyItem) {
      _resultItems.add(S2Choice<String>(
          value: companyItem.id.toString(), title: companyItem.name));
    });

    return _resultItems;
  }

  @override
  Widget build(BuildContext context) {
    return SmartSelect<String>.single(
      tileBuilder: (context, state) {
        var _value = state.selected.value;
        return CustomSmartSelectTile(
            state: state,
            after: _value != "-1"
                ? Icon(Icons.document_scanner, color: Colors.grey)
                : null,
            title: state.selected.title);
      },
      selectedValue: controller.text,
      modalFilter: true,
      modalFilterHint: "поиск",
      modalFilterAuto: true,
      onChange: (state) {
        controller.text = state.value;
        print(state.value);
      },
      title: "Компания",
      choiceItems: getItems(),
    );
  }
}
