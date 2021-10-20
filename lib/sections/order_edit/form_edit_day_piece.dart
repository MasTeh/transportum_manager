import 'package:flutter/material.dart';
import 'package:transportumformanager/global/appstorage/AppStorage.dart';
import 'package:smart_select/smart_select.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';

import 'custom_tile.dart';

class FormEditDayPiece extends StatelessWidget {
  final TextEditingController controller;
  const FormEditDayPiece({Key key, this.controller}) : super(key: key);

  List<S2Choice<String>> getItems() {
    List<S2Choice<String>> _resultItems = [];
    _resultItems.add(S2Choice<String>(title: "не указано", value: "-1"));

    _resultItems.add(S2Choice<String>(value: '0', title: '1 - Первая'));
    _resultItems.add(S2Choice<String>(value: '1', title: '2 - Вторая'));
    _resultItems.add(S2Choice<String>(value: '2', title: '3 - Третья'));
    _resultItems.add(S2Choice<String>(value: '3', title: '4 - Четвертая'));
    _resultItems.add(S2Choice<String>(value: '4', title: '5 - Пятая'));
    _resultItems.add(S2Choice<String>(value: '5', title: '6 - Шестая'));

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
      title: "Часть дня",
      choiceItems: getItems(),
    );
  }
}
