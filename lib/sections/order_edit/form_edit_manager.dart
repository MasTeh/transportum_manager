import 'package:flutter/material.dart';
import 'package:transportumformanager/global/appstorage/AppStorage.dart';
import 'package:smart_select/smart_select.dart';
import 'package:transportumformanager/helper/log.dart';
import 'package:transportumformanager/model/user_driver.dart';
import 'package:transportumformanager/model/user_manager.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';

import 'custom_tile.dart';

class FormEditManager extends StatelessWidget {
  final TextEditingController controller;
  const FormEditManager({Key key, this.controller}) : super(key: key);

  List<S2Choice<String>> getManagerItems() {
    List<S2Choice<String>> _resultItems = [];
    _resultItems
        .add(S2Choice<String>(title: "не указано", value: "-1", group: ""));

    int userIdOnly = AppData().getUser().id;
    bool loadAllUsers = false;
    if (AppData().getUser().isSuperAdmin) loadAllUsers = true;

    AppStorage().managers.forEach((managerId, managerItem) {
      bool _enabled = false;
      if ((!loadAllUsers && userIdOnly == managerId) || loadAllUsers) {
        _enabled = true;
      }

      _resultItems.add(S2Choice<String>(
          disabled: !_enabled,
          style: S2ChoiceStyle(
              titleStyle:
                  TextStyle(color: Colors.black, fontSize: 14)),
          value: managerItem.id.toString(),
          title: managerItem.login + (managerItem.name != null ? ' - '+managerItem.name : '')));
    });

    return _resultItems;
  }

  @override
  Widget build(BuildContext context) {
    return SmartSelect<String>.single(
      tileBuilder: (context, state) {
        String _value = controller.text;
        
        return CustomSmartSelectTile(
            state: state,
            after:
                _value != "-1" ? Icon(Icons.person_outline, color: Colors.black) : null,
            title: state.selected.title);
      },
      selectedValue: controller.text,
      onChange: (state) {
        controller.text = state.value;
      },
      choiceLayout: S2ChoiceLayout.wrap,
      modalType: S2ModalType.bottomSheet,
      title: "Менеджер",
      choiceItems: getManagerItems(),
    );
  }
}
