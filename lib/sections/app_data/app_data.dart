import 'dart:async';

import 'package:logger/logger.dart';
import 'package:transportumformanager/global/ChangesListener.dart';
import 'package:transportumformanager/model/user_driver.dart';
import 'package:transportumformanager/model/user_manager.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:transportumformanager/sections/app_data/app_data_api.dart';

// зона ответственности:
// 1 - данные текущего пользователя (авторизация, зарплата), 2 - настройки приложения
class AppData {
  // singletone
  static final AppData _instance = AppData._internal();

  UserManager _currentUser;
  List<UserDriver> allDrivers;
  String clientName;
  String role;
  SharedPreferences prefs;
  String currentSalary;
  Logger log = Logger();

  final int dashboardPreloadCount = 10;

  ChangesListener changeListener = ChangesListener();

  bool stateChanged = false;

  void setCurrentUser(UserManager user) {
    _currentUser = user;
  }

  UserManager getUser() {
    return _currentUser;
  }

  factory AppData() {
    return _instance;
  }

  void clear() {
    _currentUser = null;
    clientName = null;
    role = null;
    prefs = null;
  }

  AppData._internal();
}
