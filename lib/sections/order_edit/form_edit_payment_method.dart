import 'package:flutter/material.dart';
import 'package:transportumformanager/global/appstorage/AppStorage.dart';
import 'package:smart_select/smart_select.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';

import 'custom_tile.dart';

class FormEditPaymentMethod extends StatelessWidget {
  final TextEditingController controller;
  const FormEditPaymentMethod({Key key, this.controller}) : super(key: key);

  List<S2Choice<String>> getItems() {
    List<S2Choice<String>> _resultItems = [];
    _resultItems.add(S2Choice<String>(title: "не указано", value: "-1"));

    _resultItems.add(S2Choice<String>(value: 'Безнал с НДС', title: 'Безнал с НДС'));
    _resultItems.add(S2Choice<String>(value: 'Безнал без НДС', title: 'Безнал без НДС'));
    _resultItems.add(S2Choice<String>(value: 'Наличный', title: 'Наличный'));

    return _resultItems;
  }

  @override
  Widget build(BuildContext context) {
    return SmartSelect<String>.single(
      tileBuilder: (context, state) {
        String _value = controller.text;
        String _title = state.selected.title;

        state.selected.value = _value;

        return CustomSmartSelectTile(state: state, title: _title);
      },
      selectedValue: controller.text,
      onChange: (state) {
        controller.text = state.value;
      },
      choiceLayout: S2ChoiceLayout.wrap,
      modalType: S2ModalType.bottomSheet,
      title: "Способ оплаты",
      choiceItems: getItems(),
    );
  }
}
