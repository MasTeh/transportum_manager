// область ответственности: получение данных от сервера для класса деталей заявки

import 'dart:async';

import 'package:transportumformanager/model/order.dart';
import 'package:transportumformanager/model/photo.dart';
import 'package:transportumformanager/network/query.dart';
import 'package:transportumformanager/network/socket.dart';

class _OrderEditAPIErrors {
  final String error1 = "error1";
}

class OrderEditAPI {
  static _OrderEditAPIErrors errors = _OrderEditAPIErrors();

  Future<dynamic> getAutocomplete(String query, String owner, String field) {
    Completer completer = Completer();
    TransportumSocket().query(
        SocketQuery("get_autocomplete")
            .addParam('query', query)
            .addParam('owner', owner)
            .addParam('field', field), callback: (response) {
      completer.complete(Map<String, dynamic>.from(response));
    });

    return completer.future;
  }

  Future<dynamic> checkOrderExist(String date, String transportId, String orderNum) {
    Completer completer = Completer();
    TransportumSocket().query(
        SocketQuery("check_order_exist")
            .addParam('date', date)
            .addParam('transport_id', transportId)
            .addParam('order_num', orderNum), callback: (response) {
      completer.complete(Map<String, dynamic>.from(response));
    });

    return completer.future;
  }

  Future<dynamic> checkTrailerExist(String date, String transportId, String orderNum) {
    Completer completer = Completer();
    TransportumSocket().query(
        SocketQuery("check_trailer")
            .addParam('date', date)
            .addParam('transport_id', transportId)
            .addParam('order_num', orderNum), callback: (response) {
      completer.complete(Map<String, dynamic>.from(response));
    });

    return completer.future;
  }


  Future<dynamic> addOrder(OrderModel order) {
    Completer completer = Completer();
    TransportumSocket().query(
        SocketQuery("add_order")
          .addParam('order', order.toJSON(withUpdateId: true))
          .addParam('group', null), callback: (response) {
            completer.complete(Map<String, dynamic>.from(response));
    });

    return completer.future;
  }
}