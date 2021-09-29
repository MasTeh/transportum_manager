import 'package:flutter/material.dart';
import 'package:transportumformanager/global/appstorage/AppStorage.dart';
import 'package:smart_select/smart_select.dart';
import 'package:transportumformanager/helper/log.dart';
import 'package:transportumformanager/sections/order_edit/custom_tile.dart';

class FormEditTransport extends StatelessWidget {
  final TextEditingController controller;
  final Function callbackForDriverChange;
  const FormEditTransport(
      {Key key, this.controller, this.callbackForDriverChange})
      : super(key: key);

  List<S2Choice<String>> getTransportItems() {
    List<S2Choice<String>> _resultItems = [];
    _resultItems
        .add(S2Choice<String>(title: "не указано", value: "-1"));

    AppStorage().transports.forEach((transportId, transportItem) {
      String sublabel;

      sublabel = transportItem.techFunction;

      if (transportItem.isOwn && transportItem.techFunction != "")
        sublabel += ", наша техника";
      if (transportItem.isOwn && transportItem.techFunction == "")
        sublabel += "Наша техника";

      if (!transportItem.isOwn && transportItem.companyId != 0) {
        try {
          String companyName =
              AppStorage().getCompany(transportItem.companyId).name;
          if (sublabel != "")
            sublabel += ", " + companyName;
          else
            sublabel = companyName;
        } catch (err) {}
      }

      String _groupName = "Своя техника";
      if (!transportItem.isOwn) _groupName = "Привлечёнка";

      _resultItems.add(S2Choice<String>(
          style: S2ChoiceStyle(
              titleStyle: transportItem.isOwn
                  ? TextStyle(
                      color: Colors.green[700], fontWeight: FontWeight.bold)
                  : null),
          subtitle: sublabel != "" ? sublabel : null,
          value: transportItem.id.toString(),
          group: _groupName,
          title: '${transportItem.modelName} ${transportItem.number}'));
    });
    return _resultItems;
  }

  @override
  Widget build(BuildContext context) {
    return SmartSelect<String>.single(
      tileBuilder: (context, state) {
        String title, icon;
        if (state.selected.value == '-1') {
          title = null;
          icon = null;
        } else {
          int companyId = AppStorage()
              .getTransport(int.parse(state.selected.value))
              .companyId;

          if (!AppStorage()
              .getTransport(int.parse(state.selected.value))
              .isOwn) {
            title = state.selected.title +
                '\n(' +
                AppStorage().getCompany(companyId).name +
                ')';
          }

          icon = AppStorage()
              .getTransport(int.parse(state.selected.value))
              .getIconAssetName();
        }

        return CustomSmartSelectTile(
            state: state,
            title: title,
            after: icon != null ? Image.asset(icon, width: 20) : null);

        // return S2Tile.fromState(state,
        //     isTwoLine: false,
        //     title: Text("Транспорт"),
        //     value: Text(title, overflow: TextOverflow.ellipsis),
        //     trailing: icon != null ? Image.asset(icon, width: 20) : null);
      },
      groupSortBy: S2GroupSort.byCountInAsc(),
      groupEnabled: false,
      selectedValue: controller.text,
      modalFilter: true,
      groupCounter: false,
      groupHeaderStyle: S2GroupHeaderStyle(
          textStyle: TextStyle(fontSize: 18),
          backgroundColor: Colors.grey[200]),
      modalFilterHint: "поиск",
      modalFilterAuto: true,
      onChange: (state) {
        controller.text = state.value;
        if (callbackForDriverChange != null)
          this.callbackForDriverChange(state.value);
      },
      title: "Транспорт",
      choiceItems: getTransportItems(),
    );
  }
}
