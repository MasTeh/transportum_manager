import 'dart:async';
import 'dart:developer';

import 'package:transportumformanager/network/query.dart';
import 'package:transportumformanager/network/socket.dart';

// область ответственности: получение данных от сервера для класса AppData

class AppDataAPIErrors {
  final int noResult = 1;
  final Map<int, String> errorMessages = {1: "В ответе сервера отсутствует result = ok"};

  String getErrorMessage(int errorCode) {
    return errorMessages[errorCode];
  }
}

class AppDataAPI {
  static AppDataAPIErrors _errors = AppDataAPIErrors();

  static void _errorHandler(int errorCode) {
    log.e(AppDataAPI._errors.getErrorMessage(AppDataAPI._errors.noResult));
  }
}
