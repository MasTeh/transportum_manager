import 'dart:async';

import 'package:transportumformanager/network/query.dart';
import 'package:transportumformanager/network/socket.dart';

class _AppStorageApiErrors {
  final int noResult = 1;
  final Map<int, String> errorMessages = {
    1: "В ответе сервера отсутствует result = ok"
  };

  String getErrorMessage(int errorCode) {
    return errorMessages[errorCode];
  }
}

class AppStorageApi {
  static _AppStorageApiErrors _errors = _AppStorageApiErrors();

  static void _errorHandler(int errorCode) {
    log.e(
        AppStorageApi._errors.getErrorMessage(AppStorageApi._errors.noResult));
  }

  Future<dynamic> getDrivers() {
    Completer completer = Completer();
    TransportumSocket().query(SocketQuery('get_drivers'), callback: (response) {
      if (response['result'] == 'ok') {
        completer.complete(Map<String, dynamic>.from(response));
      } else {
        int _errorCode = AppStorageApi._errors.noResult;
        AppStorageApi._errorHandler(_errorCode);
      }
    });
    return completer.future;
  }

  Future<dynamic> getTransports() {
    Completer completer = Completer();
    TransportumSocket().query(SocketQuery('get_transports'),
        callback: (response) {
      if (response['result'] == 'ok') {
        completer.complete(List<dynamic>.from(response['items']));
      } else {
        int _errorCode = AppStorageApi._errors.noResult;
        AppStorageApi._errorHandler(_errorCode);
      }
    });
    return completer.future;
  }

  Future<dynamic> getCompanies() {
    Completer completer = Completer();
    TransportumSocket().query(SocketQuery('get_companies_flutter'),
        callback: (response) {
      
      if (response['result'] == 'ok') {
        completer.complete(List<dynamic>.from(response['items']));
      } else {
        int _errorCode = AppStorageApi._errors.noResult;
        AppStorageApi._errorHandler(_errorCode);
      }
    });
    return completer.future;
  }

  Future<dynamic> getManagers() {
    Completer completer = Completer();
    TransportumSocket().query(SocketQuery('get_users'),
        callback: (response) {
      
      if (response['result'] == 'ok') {
        completer.complete(List<dynamic>.from(response['items']));
      } else {
        int _errorCode = AppStorageApi._errors.noResult;
        AppStorageApi._errorHandler(_errorCode);
      }
    });
    return completer.future;
  }
}
