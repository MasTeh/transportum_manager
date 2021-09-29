import 'package:transportumformanager/model/dashboard_item.dart';
import 'package:transportumformanager/sections/home/dashboard/dashboard_item.dart';

class DashBoardListModel {
  final List<DashBoardItemModel> items;

  const DashBoardListModel(this.items);

  factory DashBoardListModel.fromJSON(Map<String, dynamic> jsonData) {
    List<DashBoardItemModel> gettedItems = [];

    if (jsonData['result'] == 'ok') {
      var jsonItems = Map<String, dynamic>.from(jsonData['items']);
      jsonItems.forEach((key, value) {
        gettedItems.add(DashBoardItemModel.fromJSON(value));
      });
    }
    return DashBoardListModel(gettedItems);
  }
}
