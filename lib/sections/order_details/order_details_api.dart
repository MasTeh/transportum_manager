// область ответственности: получение данных от сервера для класса деталей заявки

import 'dart:async';

import 'package:transportumformanager/network/query.dart';
import 'package:transportumformanager/network/socket.dart';

class _OrderDetailsApiErrors {
  final String orderNotFound = "orderNotFound";
}

class OrderDetailsApi {
  static _OrderDetailsApiErrors errors = _OrderDetailsApiErrors();

  Future<dynamic> loadOrder(int orderId) {
    Completer completer = Completer();

    TransportumSocket().query(SocketQuery('get_order').addParam('id', orderId),
        callback: (dynamic order) {
      if (order == null) completer.completeError(errors.orderNotFound);

      completer.complete(order);

    });

    return completer.future;
  }

  Future<dynamic> removeOrder(int orderId) {
    Completer completer = Completer();

    TransportumSocket().query(SocketQuery('remove_item')
      .addParam('owner', 'orders')
      .addParam('item_id', orderId),
        callback: (dynamic response) {      
        completer.complete(response);

    });

    return completer.future;
  }
}
