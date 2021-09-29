// область ответственности: получение данных от сервера для класса деталей заявки

import 'dart:async';

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

  Future<dynamic> loadOrder(int orderId) {}
}
