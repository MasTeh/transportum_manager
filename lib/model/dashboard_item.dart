import 'package:transportumformanager/model/order.dart';

class DashBoardItemModel {
  final int transportId;
  final String transportNumber;
  final bool isOwnTransport;
  final List<OrderModel> orders;

  const DashBoardItemModel(
      this.transportId, this.transportNumber, this.isOwnTransport, this.orders);

  factory DashBoardItemModel.fromJSON(Map<String, dynamic> jsonData) {
    var jsonOrders = List<dynamic>.from(jsonData['items']);
    List<OrderModel> gettedOrders = [];
    jsonOrders.forEach((element) {
      gettedOrders.add(OrderModel.fromJSON(element));
    });

    gettedOrders.sort((a, b) {
      int time1 = 0;
      int time2 = 0;
      try {
        time1 = int.parse((a.time).replaceAll(':', ''));
        time2 = int.parse((b.time).replaceAll(':', ''));
      } catch (err) {}

      return time1.compareTo(time2);
    });

    bool _isOwn = false;
    if ((jsonData['transport']['type'] as int) == 1) _isOwn = true;
    return DashBoardItemModel(jsonData['transport']['id'] as int,
        jsonData['transport']['number'] as String, _isOwn, gettedOrders);
  }
}
