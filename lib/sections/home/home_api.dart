// область ответственности: получение данных от сервера для класса главного экрана

import 'dart:async';

import 'package:transportumformanager/model/dashboard_item.dart';
import 'package:transportumformanager/model/dashboard_list.dart';
import 'package:transportumformanager/network/query.dart';
import 'package:transportumformanager/network/socket.dart';

class _HomeApiErrors {
  final String error1 = "Error";
}

class HomeApi {
  static _HomeApiErrors errors = _HomeApiErrors();

  Future<dynamic> getDashBoardPage(String webDate) {
    Completer completer = Completer();
    TransportumSocket()
        .query(SocketQuery("get_orders_flutter").addParam("date", webDate),
            callback: (response) {
      
      var result = DashBoardListModel.fromJSON(response);
      completer.complete(result);
    });
    return completer.future;
  }
}
